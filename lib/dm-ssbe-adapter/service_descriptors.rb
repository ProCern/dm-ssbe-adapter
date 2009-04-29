require 'extlib'

module DataMapper::Adapters
  module Services

    class ServicesCollection
      attr_accessor :http

      def initialize(http_accessor, services_uri)
        @http, @services_uri = http_accessor, services_uri
      end

      def mime_type
        'application/vnd.absperf.ssbe+json'
      end

      def service_descriptors(service_name)
        @services ||= {}

        if @services.has_key?(service_name)
          @services[service_name]
        else
          node = document['items'].detect do |service|
            service['name'] == service_name
          end

          @service_descriptors[service_type] = 
            Service.new(http, service_type, node['href'])
        end
      end

      def document
        resp = http.resource(@services_uri, :accept => mime_type).get

        # only bother re-parsing the JSON if the document has changed
        if resp.header['ETag'] != @etag
          @etag = resp.header['ETag']
          @document = parse(resp.body)
        end

        @document
      end

      def parse(text)
        Mash.new(JSON.parse(text))
      end

      def create(service_type, href)
        json_doc = JSON.generate(:service_type => service_type,
                                 :href => href)
        res = http.resource(@href, 
                            :accept => ServiceIdentifiers[:kernel].mime_type)

        res.post(json_doc,
                 :content_type => ServiceIdentifiers[:kernel].mime_type)
      end
    end

    class ServiceDescriptor
      attr_accessor :http, :service_type, :href

      def initialize(http_accessor, service_type, href)
        @http = http_accessor
        @service_type, @href = service_type, href
      end

      def [](resource_name)
        resource_descriptors(resource_name)
      end

      def resource_descriptors(resource_name)
        @resource_descriptors ||= {}

        if @resource_descriptors.has_key?(resource_name)
          @resource_descriptors[resource_name]
        else
          node = document['items'].detect do |resource_descriptor|
            resource_descriptor['name'] == resource_name
          end

          @resource_descriptors[resource_name] = 
            ResourceDescriptor.new(http, resource_name, node['href'], mime_type)
        end
      end

      def service_identifier
        ServiceIdentifiers[service_type]
      end

      def mime_type
        service_identifier.mime_type
      end

      def document
        resp = http.resource(@href, :accept => ServiceIdentifiers[:kernel].mime_type).get

        # only bother re-parsing the JSON if the document has changed
        if resp.header['ETag'] != @etag
          @etag = resp.header['ETag']
          @document = parse resp.body
        end

        @document
      end

      def parse(text)
        Mash.new(JSON.parse(text))
      end

    end

  end
end
