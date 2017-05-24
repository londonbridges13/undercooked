module ResourcesHelper

  def test_resource(resource)
    # search the url for articles, but don't create anything
    check_resource(resource)
  end

  def check_resource(resource) #should be the same as ArticlesHelper
    if resource.resource_type == "error"
      #do nothing
      present "This resoruce has it's own error"
    elsif resource.resource_type == "article-xml" #or resource.resource_url.include? "autoimmunewellness.com" or
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



    # Channel Functions

    def recommend_channels_by_topics(topics)
      # present channels based on the topics that the user follows
      @channels = []

      topics.each do |t|
        recommend_channel t
      end


      # change channel to article, for the image
      channels = []
      @channels.each do |c|
        display = Article.new(id: c.id, title: c.title, article_image_url: c.image.url)
        channels.push display
      end
      present channels
    end

    def recommend_channel(topic)
      # from this one topic, suggest 3 channels that are not yset in the @channels
      # find the channels with the must content under this topic (within last 30 days)

      x_days = 30
      # Grab content from the last 30 days
      articles = topic.articles.where('article_date > ?', x_days.days.ago)

      potential_channels = []
      articles.each do |a|
        potential_channels.push a.resource
      end

      counts = {}
      potential_channels.group_by(&:itself).each { |k,v| counts[k] = v.length }

      counts.sort_by{|x,y| y}.reverse # order by number of appearances, highest to lowest

      added_channels = 0 #number of channels added by this topic
      counts.each do |c|
        # add channels to the @channels
        # stop when you've added 3 channels
        unless added_channels == 3
          unless @channels.include? c[0]
            @channels.push c[0]
            added_channels += 1
          end
        end
      end

    end




end
