module ResourcesHelper

  def test_resource(resource)
    # search the url for articles, but don't create anything
    check_resource(resource)
  end

  def check_resource(resource) #should be the same as ArticlesHelper
    if resource.resource_type == "error"
      #do nothing
      present "This resoruce has it's own error"
    elsif resource.resource_url.include? "autoimmunewellness.com" or resource.resource_type == "article-xml"
      # the weird articles that cause errors
      get_other_articles(resource)
    elsif resource.resource_url.include? "youtube.com" or resource.resource_type == "video"
      # Check for videos in this resource
      get_youtube_videos(resource)
    else
      # Check for articles in this resource
      get_articles(resource)
    end
  end



  #Check Resource Functions

    def get_youtube_videos(resource)
      # this gets the other a youtube channel's videos using Feedjira::fetch_and_parse
      # resource.resource_url.include? "youtube.com" , should be true
        # Check for videos in this resource
        #able_to_parse
        url =  resource.resource_url#"http://feeds.feedburner.com/MinimalistBaker?format=xml"
        #xml = Faraday.get(url).body.force_encoding('utf-8')
        feed = Feedjira::Feed.fetch_and_parse url #for munchies  #resource.resource_url#force_encoding('UTF-8')
        if feed.entries.count > 0
          present "Successful Test"

        else
          present "Found Nothing, but still Successful"
        end
    end

    def get_articles(resource)
      # this gets the other articles using Feedjira::parse
      # Check for articles in this resource
      url =  resource.resource_url#"http://feeds.feedburner.com/MinimalistBaker?format=xml"
      xml = Faraday.get(url).body.force_encoding('utf-8')
      puts url
      feed = Feedjira::Feed.parse xml#url#resource.resource_url#force_encoding('UTF-8')
      if feed.entries.count > 0
        present "Successful Test"

      else
        present "Found Nothing, but still Successful"
      end
    end



    def get_other_articles(resource)
      # this gets the other articles using Feedjira::fetch_and_parse

      url =  resource.resource_url#"http://feeds.feedburner.com/MinimalistBaker?format=xml"
      # xml = Faraday.get(url).body.force_encoding('utf-8')
      puts url
      feed = Feedjira::Feed.fetch_and_parse url#resource.resource_url#force_encoding('UTF-8')
      if feed.entries.count > 0
        present "Successful Test"

      else
        present "Found Nothing, but still Successful"
      end
    end





end
