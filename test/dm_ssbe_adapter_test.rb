require 'test_helper'

DataMapper.setup(:default, :adapter => :ssbe,
                 :username => 'admin',
                 :password => 'admin',
                 :services_uri => 'http://localhost:5050/services')

Testy.testing 'dm-ssbe-adapter' do
  test 'connecting' do |r|
    r.check :services,
            :expect => 'AllServices',
            :actual => Service.first.name
  end

  test 'reading attributes' do |r|
    service = Service['AllServices']
    puts service.inspect

    r.check :string,
      :expect => 'AllServices',
      :actual => service.name

    r.check :href,
      :expect => 'http://localhost:5050/services',
      :actual => service.resource_href

    r.check :datetimes,
      :expect => DateTime.parse('2009-04-29T15:53:00-06:00'),
      :actual => service.created_at
  end
end
