
#require 'dm-core'
require 'resourceful'
require 'extlib'
require 'json'

__DIR__ = File.dirname(__FILE__)
require File.join(__DIR__, 'dm-ssbe-adapter', 'ssbe_authenticator')
require File.join(__DIR__, 'dm-types', 'href')
require File.join(__DIR__, 'dm-ssbe-adapter', 'service')
require File.join(__DIR__, 'dm-ssbe-adapter', 'model_extensions')

module DataMapper::Adapters

  class HttpAdapter < AbstractAdapter
    attr_reader :http

    def initialize(name, options = {})
      super

      @http = Resourceful::HttpAccessor.new
      @http.cache_manager = Resourceful::InMemoryCacheManager.new
      @http.logger = options[:logger] || Resourceful::BitBucketLogger.new
    end

    def logger
      http.logger
    end
  end

  class SsbeAdapter < HttpAdapter
    attr_reader :services_uri

    SSJ = 'application/vnd.absperf.ssbe+json'

    def initialize(name, options = {})
      super

      username, password = options[:username], options[:password]

      http.add_authenticator(Resourceful::SSBEAuthenticator.new(username, password))

      @services_uri = options[:services_uri]
    end

    def create(resources)
      resources.each do |resource|
        http_resource = collection_resource_for(resource)
        document = serialize(resource)

        response = http_resource.post(document, :content_type => SSJ)

        update_attributes(resource, deserialize(response.body))
      end
    end

    def read(query)
      ## [dm-core] need an easy way to determine if we're 
      # looking up a single record by key
      if querying_on_href?(query)
        operand = query.conditions.operands.first
        href = case operand.subject
               when DataMapper::Property
                 operand.value
               when DataMapper::Associations::Relationship
                 property_name = "#{operand.subject.inverse.name}_href".to_sym
                 operand.value.attribute_get(property_name)
               end

        http_resource = http.resource(href, :accept => SSJ)
        begin
          response = http_resource.get
        rescue Resourceful::UnsuccessfulHttpRequestError => e
          if e.http_response.code == 404
            return []
          else
            raise e
          end
        end
        record = deserialize(response.body)
        if record.has_key?(:items) 
          query.filter_records(record[:items])
        else
          [record]
        end
      else 
        resource = collection_resource_for(query)
        opts = {}
        opts.merge(:cache_control => 'no-cache') if query.reload?

        response = resource.get(opts)

        records = deserialize(response.body)
        query.filter_records(records[:items])
      end
    end

    def update(attributes, collection)
      collection.each do |resource|
        http_resource = http.resource(resource.href, :accept => SSJ)
        response = http_resource.put(serialize(attributes), :content_type => SSJ)

        update_attributes(resource, deserialize(response.body))
      end
    end

    def delete(collection)
      collection.each do |resource|
        http_resource = http.resource(resource.href, :accept => SSJ)
        response = http_resource.delete

        update_attributes(resource, deserialize(response.body))
      end
    end

    protected

    ## [dm-core] resource.update_fields(attributes)
    # updates any changed fields from a response
    # eg, created_at, updated_at, etc...
    def update_attributes(resource, attributes)
      attributes.each do |field, value|
        property = resource.model.properties.detect { |p| p.field == field }
        property.set!(resource, value) if property
      end
      resource
    end

    def serialize(resource_or_attributes)
      if resource_or_attributes.is_a?(DataMapper::Resource)
        attributes_as_fields(resource_or_attributes.dirty_attributes)
      else
        attributes_as_fields(resource_or_attributes)
      end.merge(:_type => resource_or_attributes.model).to_json
    end

    def deserialize(document)
      Mash.new(JSON.parse(document))
    end

    def querying_on_href?(query)
      return false unless query.conditions.operands.size == 1

      operand = query.conditions.operands.first
      return false unless operand.is_a?(DataMapper::Query::Conditions::EqualToComparison)

      case operand.subject
      when DataMapper::Property
        # .get("http://articles/1")
        query.model.key.first == operand.subject
      when DataMapper::Associations::OneToMany::Relationship
        # many to one (comment.article), but DM inverts it for the query
        true
      end
    end

    def collection_resource_for(object)
      if object.is_a?(DataMapper::Query)
        query = object
        model = query.model
      elsif object.is_a?(DataMapper::Model)
        model = object
      elsif object.is_a?(DataMapper::Resource)
        resource = object
        model = resource.model
      else
        raise ArgumentError, "Unable to determine collection resource for #{object}"
      end

      collection_uri = if model == Service
                         @services_uri
                       elsif query && uri = association_collection_uri(query)
                         uri
                       elsif model && service = Service[model.service_name]
                         service.resource_href
                       elsif resource 
                         # TODO: make this work if there's more than one relationship defined
                         # on the child, and just more robust in general
                         relationship = resource.model.relationships.values.first
                         parent_relationship = relationship.inverse
                         parent_property_name = "#{parent_relationship.name}_href".to_sym
                         parent_resource = resource.send(relationship.name)

                         parent_resource.attribute_get(parent_property_name)
                       end

      http.resource(collection_uri, :accept => SSJ)
    end

    def association_collection_uri(query)
      return false unless query.conditions.operands.size == 1

      operand = query.conditions.operands.first
      return false unless operand.is_a?(DataMapper::Query::Conditions::EqualToComparison)

      case operand.subject
      when DataMapper::Property
        operand.value
      when DataMapper::Associations::ManyToOne::Relationship
        # DataMapper passes it to the adapters backwards, so this is for
        # article.comments 
        inverse_relationship = operand.subject.inverse
        property_name = "#{inverse_relationship.name}_href".to_sym
        operand.value.attribute_get(property_name)
      end
    end

  end

end


