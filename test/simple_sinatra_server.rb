
require 'sinatra/base'

class App < Sinatra::Base

  SSJ = 'application/vnd.absperf.ssbe+json'

  before do
    content_type SSJ
  end

  get '/services' do
    <<-JSON
{
  "href":       "http://localhost:5050/services",
  "item_count": 1,
  "items":      [
{
  "_type":         "Service",
  "href":          "http://localhost:5050/services/AllServices",
  "name":          "AllServices",
  "resource_href": "http://localhost:5050/services",
  "created_at":    "2009-04-29T15:53:00-06:00",
  "updated_at":    "2009-04-29T15:53:00-06:00"
}
  ]
}
    JSON
  end

end
