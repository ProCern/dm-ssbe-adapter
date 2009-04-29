
require 'dm-core'
require 'resourceful'
require 'extlib'
require 'json'

__DIR__ = File.dirname(__FILE__)
require File.join(__DIR__, 'dm-ssbe-adapter', 'ssbe_authenticator')
require File.join(__DIR__, 'dm-types', 'href')
require File.join(__DIR__, 'dm-ssbe-adapter', 'service')

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
        http_resource = collection_resource_for(resource.model)
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
        href = operand.value

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
        [record]
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
        resource_or_attributes.attributes(:field).merge(:_type => resource_or_attributes.model)
      else
        attributes_as_fields(resource_or_attributes).merge(:_type => resource_or_attributes.keys.first.model)
      end.to_json
    end

    def deserialize(document)
      Mash.new(JSON.parse(document))
    end

    def querying_on_href?(query)
      return false unless query.conditions.operands.size == 1

      operand = query.conditions.operands.first
      return false unless operand.is_a?(DataMapper::Conditions::EqualToComparison)

      query.model.key.first == operand.property
    end

    def collection_resource_for(query_or_model)
      if query_or_model.is_a?(DataMapper::Query)
        query = query_or_model
        model = query.model
      else
        model = query_or_model
      end

      ## [dm-core] Make it easy to add more things to a query
      collection_uri = if model == Service
                         @services_uri
                       elsif query && uri = query.instance_variable_get(:@collection_uri)
                         uri
                       elsif uri = model.collection_uri
                         uri
                       else
                         Service[model.service_name].resource_href
                       end

      http.resource(collection_uri, :accept => SSJ)
    end

  end

end


