module SuggestionsHelper


  def create_suggestions_for_topic(topic)
    two_days_ago = Time.now - 3.days
    all_recent_articles = Article.potential_suggested_articles.where('article_date < ?', two_days_ago) #test

    all_recent_articles.each do |a|
        #Resource
      if topic.resources.include? a.resource
        #create suggestions
        new_suggestion = topic.suggestions.build(:reason => "Resource", :evidence => a.resource.title)
        new_suggestion.article = a
        new_suggestion.save
      else
        #Keyword
        topic.keywords.each do |k|
          # see if the keyword exists in in the article's desc or title
          if a.title.include? k
            #create suggestion
            new_suggestion = topic.suggestions.build(:reason => "Keyword", :evidence => k)
            new_suggestion.article = a
            new_suggestion.save

          elsif a.desc.include? k
            #create suggestion
            new_suggestion = topic.suggestions.build(:reason => "Keyword", :evidence => k)
            new_suggestion.article = a
            new_suggestion.save
          end
        end

      end
    end
    count_suggested_articles_of_topic(topic)
  end


  def count_suggested_articles_of_topic(topic)
    present topic.suggestions.count
  end

end
