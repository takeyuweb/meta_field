class MetaField::Meta < ActiveRecord::Base
  self.table_name = :meta_field_metas
  belongs_to :obj, polymorphic: true
end
