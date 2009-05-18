require File.dirname(__FILE__) + '/spec_helper'

describe 'creating' do

  it 'should create' do
    article = Article.create(:title => "Test Create",
                             :text => "Here's how you create an article.")

    article.published_at.should == "2009-04-29T15:53:00-06:00"
  end
end



