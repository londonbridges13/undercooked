module SuggestionsHelper


  def create_suggestions_for_topic(topic)
    remove_accepted_suggestions(topic)
    all_recent_articles = Article.where('article_date > ?', 3.days.ago).where("publish_it != ? OR publish_it IS NULL",false) #test, not working with scope

    existing_suggested_articles = topic.articles # should = topic.suggestions
    all_recent_articles.each do |a|
      unless existing_suggested_articles.include? a
        existing_suggested_articles.push a.article
      end
    end

    all_recent_articles.each do |a|
        #Resource
      if topic.resources.include? a.resource
        #create suggestions
        unless existing_suggested_articles.include? a
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
            unless existing_suggested_articles.include? a
              new_suggestion = topic.suggestions.build(:reason => "Keyword", :evidence => k)
              new_suggestion.article = a
              new_suggestion.save
            end

          elsif a.desc.include? k
            #create suggestion
            unless existing_suggested_articles.include? a
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

  def remove_accepted_suggestions(topic)
    # if the topic contains this article, we want to remove the suggestion
    suggestions = []
    topic.suggestions.each do |s|
      # get article suggestions
      if topic.articles.include? s.article
        # remove the suggestion
        s.delete # WE DON'T NEED TO KEEP A SUGGESTION IF IT WAS ACCEPTED
      end
    end
  end

end
