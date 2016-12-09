require 'sanitize' #for tweaking article description

class FeedController < ApplicationController

  def index
    search_for_articles()
  end



  def search_for_articles
    all_resources = Resource.all
    all_resources.each do |resource|
      check_resource(resource)
    end
  end

  def check_resource(resource) #resource object here
    # Check for articles in this resource
    feed = Feedjira::Feed.fetch_and_parse resource.resource_url
    feed.entries.each do |entry|
      i = 0
      while i < 3
        # Check if the entry is older than two days, and check if it exists in the articles database
        two_days_ago = Time.now - 2.days
        all_articles = Article.all.where('article_date > ?', two_days_ago) #works
        all_article_urls = []
        all_articles.each do |u|
          all_article_urls.push(u.article_url)
        end
        if entry.published > two_days_ago
          # check if contained in Article Database
          unless all_article_urls.include? entry.url
            #good to Use
            images = LinkThumbnailer.generate(entry.url)
            article_image_url = images.images.first.src.to_s

            new_article = resource.articles.build(:title => entry.title, :article_url => entry.url, :article_image_url => article_image_url,
            :desc => Sanitize.fragment(entry.summary), :resource_type => 'article', :article_date => entry.published, :publish_it => nil)#, :image)
            new_article.save
          end
        end
        i += 1
      end
    end
  end


  def remove_old_unused_articles
    # Removes all articles that are more than 2 days AND never published
    two_days_ago = Time.now - 2.days
    all_articles = Article.all.where('article_date < ? AND publish_it == ?', two_days_ago, false)
    all_articles.each do |e|
      e.delete
    end

  end


end
