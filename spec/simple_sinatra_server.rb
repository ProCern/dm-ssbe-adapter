
require 'sinatra/base'

class App < Sinatra::Base

  SSJ = 'application/vnd.absperf.ssbe+json'

  use_in_file_templates!

  before do
    content_type SSJ
  end

  get '/services' do
    erb :services
  end

  get '/articles' do
    erb :articles
  end

  post '/articles' do
    params[:id] = 1
    erb :article
  end

  get '/articles/:id' do
    erb :article
  end

  get '/articles/:article_id/comments' do
    erb :comments
  end

  get '/articles/:article_id/comments/last' do
    params[:id] = 1
    erb :comment
  end

  post '/articles/:article_id/comments' do
    erb :comment
  end

  get '/articles/:article_id/comments/:id' do
    erb :comment
  end

  get '/comments' do
    erb :comments
  end

end

__END__

@@services
{
  "href":       "http://localhost:5050/services",
  "item_count": 2,
  "items":      [
{
  "_type":         "Service",
  "href":          "http://localhost:5050/services/AllServices",
  "name":          "AllServices",
  "resource_href": "http://localhost:5050/services",
  "created_at":    "2009-04-29T15:53:00-06:00",
  "updated_at":    "2009-04-29T15:53:00-06:00"
},
{
  "_type":         "Service",
  "href":          "http://localhost:5050/services/AllArticles",
  "name":          "AllArticles",
  "resource_href": "http://localhost:5050/articles",
  "created_at":    "2009-04-29T15:53:00-06:00",
  "updated_at":    "2009-04-29T15:53:00-06:00"
},
{
  "_type":         "Service",
  "href":          "http://localhost:5050/services/AllComments",
  "name":          "AllComments",
  "resource_href": "http://localhost:5050/comments",
  "created_at":    "2009-04-29T15:53:00-06:00",
  "updated_at":    "2009-04-29T15:53:00-06:00"
}
  ]
}

@@articles
{
  "href":       "http://localhost:5050/articles",
  "item_count": 2,
  "items":      [
{
  "_type":              "Article",
  "href":               "http://localhost:5050/articles/1",
  "title":              "First Article",
  "text":               "This is the first article", 
  "comments_href":      "http://localhost:5050/articles/1/comments/latest",
  "last_comment_href":  "http://localhost:5050/articles/1/comments/latest",
  "published_at":       "2009-04-29T15:53:00-06:00",
  "updated_at":         "2009-04-29T15:53:00-06:00"
},
{
  "_type":         "Article",
  "href":          "http://localhost:5050/articles/2",
  "title":         "Second Article",
  "text":          "This is the second article", 
  "comments_href": "http://localhost:5050/articles/2/comments",
  "last_comment_href":  "http://localhost:5050/articles/2/comments/latest",
  "published_at":    "2009-04-29T15:53:00-06:00",
  "updated_at":    "2009-04-29T15:53:00-06:00"
}
  ]
}

@@article
{
  "_type":         "Article",
  "href":          "http://localhost:5050/articles/<%= params[:id] %>",
  "title":         "First Article",
  "text":          "Something different from the index, so we can get which GET we used", 
  "comments_href": "http://localhost:5050/articles/<%= params[:id] %>/comments",
  "last_comment_href":  "http://localhost:5050/articles/<%= params[:id] %>/comments/latest",
  "published_at":    "2009-04-29T15:53:00-06:00",
  "updated_at":    "2009-04-29T15:53:00-06:00"
}

@@comments
{
  "href":       "http://localhost:5050/articles/<%= params[:article_id] %>/comments",
  "item_count": 2,
  "items":      [
{
  "_type":         "Comment",
  "href":          "http://localhost:5050/articles/<%= params[:article_id] %>/comments/1",
  "author":        "Paul",
  "text":          "This is the first comment on article <%= params[:article_id] %>", 
  "article_href":  "http://localhost:5050/articles/<%= params[:article_id] %>",
  "created_at":    "2009-04-29T15:53:00-06:00",
  "updated_at":    "2009-04-29T15:53:00-06:00"
},
{
  "_type":         "Comment",
  "href":          "http://localhost:5050/articles/<%= params[:article_id] %>/comments/2",
  "author":        "Erik",
  "text":          "This is the second comment on article <%= params[:article_id] %>", 
  "article_href":  "http://localhost:5050/articles/<%= params[:article_id] %>",
  "created_at":    "2009-04-29T15:53:00-06:00",
  "updated_at":    "2009-04-29T15:53:00-06:00"
}
  ]
}

@@comment
{
  "_type":         "Comment",
  "href":          "http://localhost:5050/articles/<%= params[:article_id] %>/comments/<%= params[:id] %>",
  "author":        "Erik",
  "text":          "This is the second comment on article <%= params[:article_id] %>", 
  "article_href":  "http://localhost:5050/articles/<%= params[:article_id] %>",
  "created_at":    "2009-04-29T15:53:00-06:00",
  "updated_at":    "2009-04-29T15:53:00-06:00"
}


