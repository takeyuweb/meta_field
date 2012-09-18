# -*- coding: utf-8 -*-
require 'meta_field/proxy'

module MetaField
  module Extension
    extend ActiveSupport::Concern

    included do
      class << self
        def inherited_with_meta_field(klass) #:nodoc:
          inherited_without_meta_field klass
          if klass != MetaField::Meta
            klass.class_eval do
              scope :meta_join, ->(*args){ _meta_join(*args) }
            end
            klass.send(:include, MetaField::ModelExtension) if klass.superclass == ActiveRecord::Base
          end
        end
        alias_method_chain :inherited, :meta_field
      end

      descendants.each do |klass|
        if klass != MetaField::Meta
          klass.class_eval do
            scope :meta_join, ->(*args){ _meta_join(*args) }
          end
          klass.send(:include, MetaField::ModelExtension) if klass.superclass == ActiveRecord::Base
        end
      end
      
    end
  end
  
  module ModelExtension
    extend ActiveSupport::Concern
    
    included do
      after_save :save_meta_metas
      
      has_many :metafield_metas, class_name: 'MetaField::Meta', as: :obj, dependent: :destroy
      
      class << self

        # メタ属性を検索・ソートに使うためにJOIN
        # 
        #   # released_atの降順でソート
        #   Book.meta_join(:released_at).order('released_at DESC')
        #
        #   # priceの昇順、同一の場合はreleased_atの降順でソート
        #   Book.meta_join(:released_at, :price).order('price ASC, released_at DESC')
        #
        #   # released_atが1年前より新しものを検索し、価格の昇順でソート
        #   Book.meta_join(:released_at: Book.meta[:released_at].gt(1.years.ago), price: nil).order(:price)
        # 
        # scope ではSTIに対応できなかったのでscopeはinheritedで全クラスで定義し、クラスメソッドを呼ぶ形で対処
        # scope :meta_join, ->(*args) do
        def _meta_join(*args)
          basenames = {}
          case args.size
          when 1
            case args[0]
            when Hash
              basenames = args[0].dup
            else
              basenames[args[0]] = nil
            end
          else
            args.each{|arg| basenames[arg] = nil }
          end
          query = scoped
          basenames.each{ |basename, where_cond|
            quoted_basename = connection.quote_string(basename.to_s)
            sub = MetaField::Meta.arel_table
            sub = sub.where(sub[:basename].eq(basename))
            sub = sub.where(where_cond) if where_cond
            sub = sub.project(Arel.sql("#{connection.quote_column_name('obj_id')} as #{ connection.quote_column_name(quoted_basename+'_obj_id') }, #{connection.quote_column_name(meta_fields[basename.to_sym][0])} as #{connection.quote_column_name(quoted_basename)}"))
            query = query.joins("INNER JOIN (#{ sub.to_sql }) ON  #{connection.quote_table_name(table_name)}.#{connection.quote_column_name('id')} = #{connection.quote_column_name(quoted_basename+'_obj_id')}")
          }
          query
        end
        private :_meta_join
        
        def meta_fields
          return @meta_fields if @meta_fields
          ancestors_meta_fields = self.superclass == ActiveRecord::Base ? {} : self.superclass.meta_fields
          @meta_fields = Marshal.load(Marshal.dump(ancestors_meta_fields))
        end
      end

    end

    module ClassMethods
      # メタ属性を追加する
      # 
      #   class Book < ActiveRecord::Base
      #     attr_accessible :name, :released_at, :subtitle, :note
      #     meta_field :released_at, :datetime
      #     meta_field :subtitle,    :string
      #     meta_field :page,        :integer,  index: false
      #     meta_field :note,        :text,     default: '特記事項無し'
      #   end
      def meta_field(basename, datatype, meta_options = nil)
        meta_options = {index: true}.merge(meta_options || {})
        meta_options[:index] = false if [:text, :binary].include?(datatype.to_sym)
        datatype = "indexed_#{datatype}" if meta_options[:index]
        meta_fields[basename.to_sym] = [datatype.to_sym, meta_options]
        class_eval <<CODE
          def #{basename}_record
            unless @attributes_cache[:#{basename}_record]
              query = metafield_metas.where(basename: #{basename.to_s.inspect})
              unless obj = query.first
                obj = query.build
                obj.#{datatype} = self.class.meta_fields[:#{basename}][1][:default]
              end
              @attributes_cache[:#{basename}_record] = obj
            end
            @attributes_cache[:#{basename}_record]
          end
          private :#{basename}_record

          def #{basename}
            #{basename}_record.#{datatype}
          end

          def #{basename}=(value)
            #{basename}_record.#{datatype} = value
          end
CODE
      end
      alias :meta_attr :meta_field
      alias :meta_column :meta_field
      
     
      # meta_join でメタ属性での絞り込みを行う際にArelっぽく標記するために使うProxyを得る
      # メタ属性は単純なカラム名で扱うことができないため、Proxyを通して操作する
      #
      #   Book.meta_join(:subtitle: Book.meta[:subtitle].matches_any(['%KEYWORD1%', '%KEYWORD2%']))
      #   # => SELECT "books".*
      #   #    FROM "books" INNER JOIN (
      #   #      SELECT "obj_id" as "note_obj_id", "text" as "note"
      #   #      FROM "meta_field_metas"
      #   #      WHERE
      #   #        "meta_field_metas"."obj_type" = 'Book' AND "meta_field_metas"."basename" = 'note' AND
      #   #        ("meta_field_metas"."text" LIKE '%HOGE%' OR "meta_field_metas"."text" LIKE '%FUGA%')
      #   #    ) ON "books"."id" = "note_obj_id"
      #
      #
      #   Author.meta_join(:age: Author.meta[:age].gt(20).and(Author.meta[:age].lt(40))).order(:age)
      #   # => SELECT "authors".*
      #   #    FROM "authors" INNER JOIN (
      #   #      SELECT "obj_id" as "age_obj_id", "integer" as "age"
      #   #      FROM "meta_field_metas"
      #   #      WHERE
      #   #        "meta_field_metas"."obj_type" = 'Author' AND "meta_field_metas"."basename" = 'age AND
      #   #        "meta_field_metas"."integer" > 20 AND "meta_field_metas"."integer" < 40
      #   #     ) ON  "authors"."id" = "age_obj_id"
      #   #     ORDER BY age

      def meta
        MetaField::MetaProxy.new(self)
      end
    end

    def save_meta_metas
      self.class.meta_fields.keys.each do |basename|
        meta_record = send("#{basename}_record")
        meta_record.obj ||= self
        meta_record.save
      end
    end
    private :save_meta_metas

  end
end
