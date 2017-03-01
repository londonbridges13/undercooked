class ContentWorker
  include SuckerPunch::Job
  # workers 1

  def perform(none)
    ActiveRecord::Base.connection_pool.with_connection do
      topics = Topic.all
      topics.each do |topic|
        @cm = ContentManagement.first
        a_day_ago = Time.now - 1.day
        if topic and @cm.updated_at > a_day_ago
          puts "Checking for knew articles"
          find_new_articles_from_topic(topic)
        else
          puts "Checked in last 24 hours"
        end
      end
    end
  end




    #Get New Articles
      def find_new_articles_from_topic(topic)
        #This grabs new articles from one topic
        #Take all the resources from the topic and searches them for new articles
        topic.resources.each do |r|
          check_resource(r)
        end
        @cm.last_new_article_grab_date = "#{Time.now}"
        @cm.save
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





    # GET ARTICLES

    def get_youtube_videos(resource)
      # this gets the other a youtube channel's videos using Feedjira::fetch_and_parse
      # resource.resource_url.include? "youtube.com" , should be true
        # Check for videos in this resource
        #able_to_parse
        url =  resource.resource_url#"http://feeds.feedburner.com/MinimalistBaker?format=xml"
        #xml = Faraday.get(url).body.force_encoding('utf-8')
        feed = Feedjira::Feed.fetch_and_parse url#resource.resource_url#force_encoding('UTF-8')
        feed.entries.each do |entry|
          i = 0
          while i < 3
            # Check if the entry is older than two days, and check if it exists in the articles database
            two_days_ago = Time.now - 3.days
            all_articles = Article.all.where('article_date > ?', two_days_ago) #works
            all_article_urls = []
            all_articles.each do |u|
              all_article_urls.push(u.article_url)
            end
            if entry.published > two_days_ago
              # check if contained in Article Database
              unless all_article_urls.include? entry.url
                #good to Use
                # images = LinkThumbnailer.generate(entry.url)
                article_image_url = LinkThumbnailer.generate(entry.url).images.first.src.to_s
                # article_image_url = images.images.first.src.to_s

                new_article = resource.articles.build(:title => entry.title, :article_url => entry.url, :article_image_url => article_image_url,
                :desc => Sanitize.fragment(entry.summary), :resource_type => 'video', :article_date => entry.published, :publish_it => nil)#, :image)
                new_article.save
              end
            end
            i += 1
          end
        end
    end

    def get_articles(resource)
      # this gets the other articles using Feedjira::parse
      # Check for articles in this resource
      url =  resource.resource_url#"http://feeds.feedburner.com/MinimalistBaker?format=xml"
      xml = Faraday.get(url).body.force_encoding('utf-8')
      puts url
      feed = Feedjira::Feed.parse xml#url#resource.resource_url#force_encoding('UTF-8')
      feed.entries.each do |entry|
        i = 0
        while i < 3
          # Check if the entry is older than two days, and check if it exists in the articles database
          two_days_ago = Time.now - 3.days
          all_articles = Article.all.where('article_date > ?', two_days_ago) #works
          all_article_urls = []
          all_articles.each do |u|
            all_article_urls.push(u.article_url)
          end
          if entry.published > two_days_ago
            # check if contained in Article Database
            unless all_article_urls.include? entry.url
              #good to Use

              # get_article_image_url(entry.url)
              max_retries = 3
              times_retried = 0

              begin
                article_image_url = LinkThumbnailer.generate(entry.url, attributes: [:images], image_limit: 1, image_stats: false).images.first.src.to_s
              rescue Net::ReadTimeout => error
                if times_retried < max_retries
                  times_retried += 1
                  puts "Failed to <do the thing>, retry #{times_retried}/#{max_retries}"
                  retry
                else
                  puts "Exiting script. <explanation of why this is unlikely to recover>"
                  exit(1)
                end
              end
              # images = LinkThumbnailer.generate(entry.url)
              # if LinkThumbnailer.generate(entry.url)
              #   article_image_url = LinkThumbnailer.generate(entry.url).images.first.src.to_s
              #   # article_image_url = images.images.first.src.to_s
              # else
              #   article_image_url = nil
              # end

              new_article = resource.articles.build(:title => entry.title, :article_url => entry.url, :article_image_url => article_image_url,
              :desc => Sanitize.fragment(entry.summary), :resource_type => 'article', :article_date => entry.published, :publish_it => nil)#, :image)
              new_article.save
            end
          end
          i += 1
        end
      end
    end



    def get_other_articles(resource)
      # this gets the other articles using Feedjira::fetch_and_parse

      url =  resource.resource_url#"http://feeds.feedburner.com/MinimalistBaker?format=xml"
      # xml = Faraday.get(url).body.force_encoding('utf-8')
      puts url
      feed = Feedjira::Feed.fetch_and_parse url#resource.resource_url#force_encoding('UTF-8')
      feed.entries.each do |entry|
        i = 0
        while i < 3
          # Check if the entry is older than two days, and check if it exists in the articles database
          two_days_ago = Time.now - 3.days
          all_articles = Article.all.where('article_date > ?', two_days_ago) #works
          all_article_urls = []
          all_articles.each do |u|
            all_article_urls.push(u.article_url)
          end
          if entry.published > two_days_ago
            # check if contained in Article Database
            unless all_article_urls.include? entry.url
              #good to Use
              # images = LinkThumbnailer.generate(entry.url)
              article_image_url = LinkThumbnailer.generate(entry.url, attributes: [:images], image_limit: 1, image_stats: false).images.first.src.to_s
              # article_image_url = images.images.first.src.to_s

              new_article = resource.articles.build(:title => entry.title, :article_url => entry.url, :article_image_url => article_image_url,
              :desc => Sanitize.fragment(entry.summary), :resource_type => 'article', :article_date => entry.published, :publish_it => nil)#, :image)
              new_article.save
            end
          end
          i += 1
        end
      end
    end



end
