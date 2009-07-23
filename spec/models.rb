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

  property :comments_href,      Href
  property :last_comment_href,  Href

  has n, :comments

  has 1, :last_comment, :model => "Comment"
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

  belongs_to :article, :inverse => Article.relationships[:comments]
end


