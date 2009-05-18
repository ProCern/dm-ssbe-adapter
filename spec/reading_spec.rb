require File.dirname(__FILE__) + '/spec_helper'

describe 'reading' do

  it 'should get something by service name' do
    articles = Article.all
    articles.size.should == 2
  end

  it 'should get something by its href' do
    article = Article.get('http://localhost:5050/articles/1')
    article.text.should == "Something different from the index, so we can get which GET we used"
  end

  it 'should get a collection from a reference' do
    comments = Article.first.comments

    comments.size.should == 2
  end

  it 'should get a record from a reference' do
    article = Article.get("http://localhost:5050/articles/1")
    comment = Comment.get("http://localhost:5050/articles/1/comments/1")

    comment.article.should == article
  end

  describe 'attributes' do
    before do
      @article = Article.get("http://localhost:5050/articles/1")
    end

    it 'should get a string attribute' do
      @article.title.should == "First Article"
    end

    it 'should get an href attribute' do
      @article.comments_href.should == 'http://localhost:5050/articles/1/comments'
    end

    it 'should get a time attribute' do
      @article.published_at.should == Time.iso8601("2009-04-29T15:53:00-06:00")
    end
      

  end

end
