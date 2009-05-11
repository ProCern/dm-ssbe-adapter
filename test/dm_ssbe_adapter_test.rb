require 'test_helper'

DataMapper.setup(:default, :adapter => :ssbe,
                 :username => 'admin',
                 :password => 'admin',
                 :services_uri => 'http://localhost:5050/services',
                 :logger => Resourceful::StdOutLogger.new)

class Article
  include DataMapper::Resource
  service_name :AllArticles

  property :href,         String, :key => true
  property :title,        String
  property :text,         String
  property :published_at, DateTime

  property :comments_href, Href

  refers_to_collection_of :comments
end

class Comment
  include DataMapper::Resource

  property :href,         String, :key => true
  property :author,       String
  property :text,         String

  property :article_href, Href

  refers_to :article
end

Testy.testing 'dm-ssbe-adapter' do
  # test 'connecting' do |r|
  #   r.check :services,
  #           :expect => 'AllServices',
  #           :actual => Service.first.name
  # end

  # test 'reading attributes' do |r|
  #   service = Service['AllServices']
  #   puts service.inspect

  #   r.check :string,
  #     :expect => 'AllServices',
  #     :actual => service.name

  #   r.check :href,
  #     :expect => 'http://localhost:5050/services',
  #     :actual => service.resource_href

  #   r.check :datetimes,
  #     :expect => DateTime.parse('2009-04-29T15:53:00-06:00'),
  #     :actual => service.created_at
  # end

  # test 'getting something from its service name' do |r|
  #   articles = Article.all

  #   r.check :collection,
  #     :expect => 2,
  #     :actual => articles.size
  # end

  # test 'getting something by its href' do |r|
  #   article = Article.get('http://localhost:5050/articles/1')

  #   r.check :text,
  #     :expect => "Something different from the index, so we can get which GET we used", 
  #     :actual => article.text
  # end

  test 'getting something through an association' do |r|
    article = Article.first
    comments = article.comments

    r.check :comments,
      :expect => 2,
      :actual => comments.size
  end

end
