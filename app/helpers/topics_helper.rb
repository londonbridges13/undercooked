module TopicsHelper

  def get_articles_from(topics)
    @size = topics.count * 3
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
    present_articles # ship it

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
    two_days_ago = Time.now - 82.days # change back to 2
    potential_articles = topic.articles.where('article_date < ? AND publish_it == ?', two_days_ago, true)
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
      potential_articles = Article.where(:publish_it => true).sort_by(&:created_at).reverse.limit(5).all
      # grabs five newest articles

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

      featured_topic = Topic(:id => 4) # the id of te featured_topic should be four 1/13/17
      featured_articles = featured_topic.articles.where(:publish_it => true).sort_by(&:created_at).reverse.limit(5).all
      done = false
      i = 0
      while i < featured_articles.count and done == false
        a = featured_articles[i]
        unless @articles.include? a
          @articles.push(a)
          if count >= 3
            done = true
          end
        end
        i += 1
      end

    end
  end


  def present_articles
    # if @articles.count >= @size
      present @articles
    # end
  end

end
