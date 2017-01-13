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

  def add_articles(topic)
    two_days_ago = Time.now - 2.days # change back to 2
    potential_articles = topic.articles.where('publish_it = ? AND article_date < ?', true ,two_days_ago)
    # if potential_articles.count > 0
      # add each to @articles if they aren't in the article
      potential_articles.each do |a|
        unless @articles.include? a
          # doesn't contain this article, add it
          @articles.push(a)
        end
      end
    # end
  end

  def present_articles
    # if @articles.count >= @size
      present @articles
    # end
  end

end
