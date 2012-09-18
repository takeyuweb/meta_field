module MetaField
  class Railtie < ::Rails::Railtie #:nodoc:
    initializer 'meta_field' do |_app|
      ActiveSupport.on_load(:active_record) do
        require 'meta_field/extension'
        ::ActiveRecord::Base.send :include, MetaField::Extension
      end
    end
  end
end
