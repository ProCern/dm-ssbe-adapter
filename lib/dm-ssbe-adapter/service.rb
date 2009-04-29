
class Service
  include DataMapper::Resource

  property :href,           Href,   :key => true
  property :id,             String
  property :name,           String, :nullable => false
  property :resource_href,  Href,   :nullable => false

  property :created_at,     DateTime
  property :updated_at,     DateTime

  def self.[](name)
    first(:name => name)
  end


end
