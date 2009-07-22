require File.dirname(__FILE__) + '/spec_helper'

describe 'creating' do

  it 'should create' do
    article = Article.create(:title => "Test Create",
                             :text => "Here's how you create an article.")

    article.published_at.should == "2009-04-29T15:53:00-06:00"
  end

  describe "creating a sub-resource" do
    before do
      @article = Article.create(:title => "Test Create",
                                :text => "Here's how you create an article.")
    end

    it "should work when assigning the relationship directly" do
      comment = Comment.new(:author => "Paul",
                               :text => "Lorem Ipsum",
                               :article => @article)

      comment.article.should == @article
      comment.article_href.should == @article.href

      comment.save

      comment.href.should_not be_nil

    end

  end
end



