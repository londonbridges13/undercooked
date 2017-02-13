module SuggestionsHelper


  def create_suggestions_for_topic(topic)
    two_days_ago = Time.now - 3.days
    all_recent_articles = Article.where('article_date < ?', 3.days.ago)#.potential_suggested_articles #test, not working

    existing_suggestions = []
    topic.suggestions.each do |a|
      unless existing_suggestions.include? a
        existing_suggestions.push a.article
      end
    end

    all_recent_articles.each do |a|
        #Resource
      if topic.resources.include? a.resource
        #create suggestions
        unless existing_suggestions.include? a
          new_suggestion = topic.suggestions.build(:reason => "Resource", :evidence => a.resource.title)
          new_suggestion.article = a
          new_suggestion.save
        end
      else
        #Keyword
        topic.keywords.each do |k|
          # see if the keyword exists in in the article's desc or title
          if a.title.include? k
            #create suggestion
            unless existing_suggestions.include? a
              new_suggestion = topic.suggestions.build(:reason => "Keyword", :evidence => k)
              new_suggestion.article = a
              new_suggestion.save
            end

          elsif a.desc.include? k
            #create suggestion
            unless existing_suggestions.include? a
              new_suggestion = topic.suggestions.build(:reason => "Keyword", :evidence => k)
              new_suggestion.article = a
              new_suggestion.save
            end
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
