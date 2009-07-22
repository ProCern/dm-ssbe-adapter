class Article
  include DataMapper::Resource
  def self.default_repository_name
    :ssbe
  end

  service_name :AllArticles

  property :href,         String, :key => true
  property :title,        String
  property :text,         String
  property :published_at, Time

  property :comments_href, Href

  refers_to_collection_of :comments
end

class Comment
  include DataMapper::Resource
  def self.default_repository_name
    :ssbe
  end

  property :href,         String, :key => true
  property :author,       String
  property :text,         String

  property :article_href, Href

  refers_to :article

  collection_resource :article

end


