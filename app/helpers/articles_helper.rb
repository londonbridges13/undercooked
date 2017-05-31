module ArticlesHelper


  def search_for_articles
    all_resources = Resource.all
    all_resources.each do |resource|
      unless resource.resource_url == "=" or resource.resource_type == "="
        #check_resource(resource)
      end
    end
  end

  def check_resource(resource) #resource object here
    if resource.resource_url.include? "youtube.com"
      # Check for videos in this resource
      get_youtube_videos(resource)
    elsif resource.resource_url.include? "autoimmunewellness.com"
      # the weird articles that cause errors
      get_other_articles(resource)
    else
      # Check for articles in this resource
      get_articles(resource)
    end
  end


  def remove_old_unused_articles
    #No Longer remove rejected articles, so that user can view all of bloggers work.

    # Removes all articles that are more than 2 days AND never published
    # two_days_ago = Time.now - 3.days
    # all_articles = Article.all.where('article_date < ?', two_days_ago)
    # all_articles.each do |e|
    #   if e.publish_it == false
    #     e.suggestions.clear
    #     e.delete
    #   end
    # end
  end


  def get_articles_from(topics)
    @size = topics.count * 3
    @amount = 0
    @articles = []
    i = 0
    # while @articles.count < @size
    i += 1
    topics.each do |t|
      unless i >= topics.count #@articles.count < @size
        add_articles(t) #add_an_article(t)
      else
        add_featured_articles(@amount) #present_articles # ship it
      end
      # i += 1
    end
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

  def add_articles(topic)
    two_days_ago = Time.now - 7.days # change back to 3
    potential_articles = topic.articles.where('article_date > ?', two_days_ago).where(:publish_it => true)
    if potential_articles.count > 2 # 3 is enough
      # add each to @articles if they aren't in the article
      potential_articles.each do |a|
        unless @articles.include? a
          # doesn't contain this article, add it
          @articles.push(a)
        end
      end
    else
      # Back up Query
      potential_articles = topic.articles.limit(5).where(:publish_it => true).order("article_date DESC")#.reverse
      # grabs five newest articles from the topic

      count = 0
      ii = 0
      while ii < potential_articles.count
        #collect 2 potential_articles add to @articles
        a = potential_articles[ii]
        unless @articles.include? a or count == 2
          @articles.push(a)
          count += 1
        end
        ii += 1
      end
      # the goal above is to collect two articles from this topics
      # the goal below is to collect another article that was featured
      # also if the potential_articles didn't give 2 articles, below will provide extra articles for @articles
      # the goal is to get three articles per topic

      @amount += 3 - count # I want 3 articles. if they only got 2, search featured articles for the third

      # featured_topic = Topic(:id => 12) # the id of te featured_topic should be four 1/13/17
      # featured_articles = featured_topic.articles.where(:publish_it => true).sort_by(&:article_date).reverse.limit(5).all
      # done = false
      # i = 0
      # while i < featured_articles.count and done == false
      #   a = featured_articles[i]
      #   unless @articles.include? a
      #     @articles.push(a)
      #     if count >= 1 #shouldn't grab three featured articles for every 2 topic articles
      #       done = true
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
    featured_topic = Topic(:id => 12) # the id of te featured_topic should be four 1/13/17
    featured_articles = featured_topic.articles.limit(10).where(:publish_it => true).order("article_date DESC")
    i = 0
    count = 0
    while i < featured_articles.count and count < amount
      a = featured_articles[i]
      unless @articles.include? a
        @articles.push(a)
        count += 1
      end
      i += 1
    end

    present_articles

  end



  def get_handpicked_articles(user)


    if user
      all_articles = []
      channels = user.display_following
      channels.each do |c|
        c_articles = c.articles.order('article_date DESC').limit(3)
        c_articles.each do |a|
          unless all_articles.include? a
            all_articles.push a
          end
        end
      end

      topics = user.topics
      x = 23
      topics.each do |t|
        t.articles.where('article_date > ?', x.days.ago).order('article_date DESC').limit(3).each do |a|
          unless all_articles.include? a
            all_articles.push a
          end
        end
      end

      all_articles = all_articles.sort_by(&:article_date).reverse#('article_date DESC')
      return all_articles
    end
  end



  def recommended_content
    #shuffle all articles
    articles = []
    while articles.count < 3
      an_article = Article.where(:publish_it => true).shuffle.first
      unless articles.include? an_article
        articles.push an_article
      end
    end
    return articles
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


  def get_article_image_url(resource_url)
    article_url = LinkThumbnailer.generate(resource_url, attributes: [:images], image_limit: 1, image_stats: false).images.first.src.to_s
    article_image_url = article_url.images.first.src.to_s
  rescue LinkThumbnailer::Exceptions
    nil
  end

end
