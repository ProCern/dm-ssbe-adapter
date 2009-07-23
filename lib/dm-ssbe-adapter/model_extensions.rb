
module DataMapper

  module SsbeModelExtensions

    def service_name(name = nil)
      if name
        @service_name = name
      else
        @service_name
      end
    end

    attr_reader :parent_relationship, :parent_property_name
    def collection_resource(name = nil, opts = {})
      @parent_relationship = name
      @parent_property_name = opts[:property] || "#{self.name.to_s.downcase}s_href".to_sym
    end

  end

  Model.send(:include, SsbeModelExtensions)

end

