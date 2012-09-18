module MetaField
  class MetaProxy
    def initialize(klass)
      @klass = klass
      @type = klass.base_class.to_s
    end
    def [](basename)
      t = MetaField::Meta.arel_table
      NodeProxy.new(@klass.meta_fields[basename.to_sym][0], t[:obj_type].eq(@type).and(t[:basename].eq(basename.to_s)))
    end
  end
  
  class NodeProxy
    def initialize(datatype, obj)
      @datatype = datatype
      @obj = obj
    end
    
    def method_missing(action, *args)
      @obj.and(MetaField::Meta.arel_table[@datatype].send(action, *args))
    end 
  end

end
