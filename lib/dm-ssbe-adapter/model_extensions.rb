
module DataMapper

  module SsbeModelExtensions

    def service_name(name = nil)
      if name
        @service_name = name
      else
        @service_name
      end
    end

    def refers_to_collection_of(collection_name, options = {})
      options.merge!(:min => 0, :max => n)
      options[:child_repository_name]  = options.delete(:repository)
      options[:parent_repository_name] = repository.name

      rel = CollectionReference.new(collection_name, nil, self, options)
      relationships(repository.name)[collection_name] = rel
    end

    def refers_to(name, options = {})
      options.merge!(:min => 0, :max => 1)
      options[:child_repository_name]  = options.delete(:repository)
      options[:parent_repository_name] = repository.name

      rel = Reference.new(name, nil, self, options)
      relationships(repository.name)[name] = rel
    end

  end

  Model.send(:include, SsbeModelExtensions)

  module SsbeQueryExtensions

    attr_accessor :location

    def initialize(repository, model, options = {})
      super
      @location = @options.fetch(:location, nil)
    end

    def assert_valid_options(options)
      location = options.delete(:location)
      super
      options[:location] = location if location
    end

  end

  class CollectionReference < Associations::OneToMany::Relationship

    # NOTE: This is why asserting valid options is a retarded idea. It
    # makes it a giant pain in the ass to extend anything. I want a 
    # :location option on query. I have to have to extend every instance
    # of a query, and set the location manually. The single commented line
    # in `#source_scope` would be all thats needed, otherwise.
    def query_for(source, other_query = nil)
      query = super
      query.extend(SsbeQueryExtensions)
      query.location = reference_property.get(source)
      query
    end

    def source_scope(source)
      #{:location => child_key.get(source)}
      {}
    end

    def reference_property
      property_name = "#{name}_href".to_sym

      parent_model.properties(parent_repository_name)[property_name]
    end

  end

  class Reference < Associations::OneToOne::Relationship

  end

end

