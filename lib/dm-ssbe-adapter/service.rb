
class Service
  include DataMapper::Resource

  def self.default_repository_name
    :ssbe
  end

  property :href,           Href,   :key => true, :serial => true
  property :name,           String, :nullable => false
  property :resource_href,  Href,   :nullable => false

  property :created_at,     DateTime
  property :updated_at,     DateTime

  def self.[](name)
    first(:name => name.to_s)
  end

  def self.register(name, resource_href)
    if service = self.first(:name => name)
      service.href = href
      service.save
    else
      service = self.create(:name => name.to_s,
                            :resource_href => href.to_s)
    end

    service
  end


end
