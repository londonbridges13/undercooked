module TopicsHelper


#Display articles
  def get_articles_from(topics)
    @size = topics.count * 3
    @amount = 0
    @articles = []
    i = 0
    # while @articles.count < @size
    topics.each do |t|
      i += 1
      # unless i == topics.count #@articles.count < @size
      add_articles(t) #add_an_article(t)
      # else
        # present_articles # ship it
      # end
    end
    add_featured_articles(@amount) #present_articles # ship it

    # end
  end

  # def add_an_article(topic)
  #   potential_articles = topic.articles.where(:publish_it => true).sort_by(&:created_at).reverse
  #   if potential_articles.count > 0
  #     done = false
  #     i = 0
  #     while i < potential_articles.count and done == false
  #       # check if articles includes
  #       unless @articles.include? potential_articles[i] # MAYBE HERE LYES THE PROBLEM
  #         #doesn't contain this article, so add it
  #         @articles.push(potential_articles[i])
  #         done = true
  #       end
  #       if potential_articles.count == 1
  #         done = true
  #       end
  #       i += 1
  #       present_articles
  #     end
  #   end
  # end

  # def add_articles(topic)
  #   two_days_ago = Time.now - 22.days # change back to 2
  #   potential_articles = topic.articles.where('publish_it = ? AND article_date > ?', true ,two_days_ago)
  #   # if potential_articles.count > 0
  #     # add each to @articles if they aren't in the article
  #     potential_articles.each do |a|
  #       unless @articles.include? a
  #         # doesn't contain this article, add it
  #         a.display_topic = topic.title
  #         @articles.push(a)
  #       end
  #     end
  #   # end
  # end

  def add_articles(topic)
    two_days_ago = Time.now - 3.days # change back to 2
    # potential_articles = topic.articles.where('publish_it = ? AND article_date > ?', true ,two_days_ago)
    potential_articles = topic.articles.where('article_date > ?', two_days_ago).where(:publish_it => true)

    if potential_articles.count > 2 # 3 is enough
      # add each to @articles if they aren't in the article
      count = 0
      potential_articles.each do |a|
        unless @articles.include? a or count == 3
          # doesn't contain this article, add it
          a.display_topic = topic.title
          if a.desc == ""
            a.desc = "From #{a.resource.title}"
          end
          @articles.push(a)
          count += 1
        end
      end
    else
      # Back up Query
      # potential_articles = topic.articles.where(:publish_it => true).limit(5).sort_by(&:created_at).reverse
      potential_articles = topic.articles.limit(5).where(:publish_it => true).order("article_date DESC")#.reverse

      # grabs five newest articles

      count = 0
      ii = 0
      while ii < potential_articles.count
        #collect 2 potential_articles add to @articles
        a = potential_articles[ii]
        unless @articles.include? a or count == 2
          a.display_topic = topic.title
          @articles.push(a)
          count += 1
        end
        ii += 1
      end
      # the goal above is to collect two articles from this topics
      # the goal below is to collect another article that was featured
      # also if the potential_articles didn't give 2 articles, below will provide extra articles for @articles
      # the goal is to get three articles per topic

      @amount += 3 - count

      # featured_topic = Topic.where(:id => 12).first # the id of te featured_topic should be four 1/13/17
      # # featured_articles = featured_topic.articles.where(:publish_it => true).limit(5).sort_by(&:created_at).reverse
      # featured_articles = featured_topic.articles.limit(10).where(:publish_it => true).order("article_date DESC")
      #
      # done = false
      # i = 0
      # while i < featured_articles.count and done == false
      #   a = featured_articles[i]
      #   unless @articles.include? a
      #     if count >= 3
      #       done = true
      #     else
      #       a.display_topic = featured_topic.title
      #       @articles.push(a)
      #     end
      #   end
      #   i += 1
      # end

    end
  end


  def present_articles
    # if @articles.count >= @size
      present @articles
    # end
  end

  def add_featured_articles(amount)
    # this querys for the amount of featured articles needed
    featured_topic = Topic.where(:id => 12).first # the id of te featured_topic should be four 1/13/17
    featured_articles = featured_topic.articles.limit(10).where(:publish_it => true).order("article_date DESC")
    i = 0
    count = 0
    while i < featured_articles.count and count < amount
      a = featured_articles[i]
      unless @articles.include? a
        a.display_topic = featured_topic.title
        @articles.push(a)
        count += 1
      end
      i += 1
    end

    present_articles

  end





  #Get New Articles
    def find_new_articles_from_topic(topic)
      #This grabs new articles from one topic
      #Take all the resources from the topic and searches them for new articles
      topic.resources.each do |r|
        check_resource(r)
      end
    end

    def check_resource(resource) #should be the same as ArticlesHelper
      if resource.resource_url.include? "youtube.com"
        # Check for videos in this resource
        get_youtube_videos(resource)
      elsif resource.resource_url.include? "autoimmunewellness.com" or resource.resource_type == "article-xml"
        # the weird articles that cause errors
        get_other_articles(resource)
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
      xml = Faraday.get(url).body.force_encoding('utf-8')
      feed = Feedjira::Feed.fetch_and_parse xml#resource.resource_url#force_encoding('UTF-8')
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
              :desc => Sanitize.fragment(entry.summary), :resource_type => 'article', :article_date => entry.published, :publish_it => nil)#, :image)
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
