
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
        href = if query.respond_to?(:location)
                 query.location
               else
                 operand = query.conditions.operands.first
                 operand.value
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
      return true if query.respond_to?(:location) && query.location

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
                       elsif query && query.respond_to?(:location)
                         query.location
                       elsif query && uri = association_collection_uri(query)
                         uri
                       else
                         Service[model.service_name].resource_href
                       end

      http.resource(collection_uri, :accept => SSJ)
    end

    def association_collection_uri(query)
      return false unless query.conditions.operands.size == 1

      operand = query.conditions.operands.first
      return false unless operand.is_a?(DataMapper::Conditions::EqualToComparison)
      return false unless operand.property.name.to_s =~ /_href\Z/

      operand.value
    end

  end

end


