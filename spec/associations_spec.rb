require File.dirname(__FILE__) + '/spec_helper'

describe 'associations' do
  before do
    @article = Article.get("http://localhost:5050/articles/1")
    @comment = Comment.get("http://localhost:5050/articles/1/comments/1")

  end

  describe "one to many" do
    it "should work" do
      @article.comments.should_not be_empty

      @article.comments.first.article_href.should == @article.href
      @article.comments.first.article.should == @article
    end
  end

  describe "many to one" do
    it "should work" do
      @comment.article.should_not be_nil
      @comment.article.should == @article
    end
  end

  describe "one to one" do
    it "should work" do
      @article.last_comment.should == @comment
    end
  end
end




