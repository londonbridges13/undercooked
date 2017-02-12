module SuggestionsHelper


  def create_suggestions_for_topic(topic)
    two_days_ago = Time.now - 3.days
    all_recent_articles = Article.potential_suggested_articles.where('article_date < ?', two_days_ago) #test

    all_recent_articles.each do |a|
        #Resource
      if topic.resources.include? a.resource
        #create suggestions

      else
        #Keyword
        topic.keywords.each do |k|
          # see if the keyword exists in in the article's desc or title
          if a.title.include? k
            #create suggestion

          elsif a.desc.include? k
            #create suggestion

          end
        end

      end
    end


  end

end
