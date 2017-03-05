module SuggestionsHelper


  def create_suggestions_for_topic(topic)
    remove_accepted_suggestions(topic)
    all_recent_articles = Article.where('article_date > ?', 3.days.ago).where("publish_it != ? OR publish_it IS NULL",false)run

    existing_suggested_articles = [] # get existing suggestions
    existing_topic_articles = topic.articles.where('article_date > ?', 3.days.ago) # get recent articles from topic

    # set existing_suggested_articles
    topic.suggestions.each do |s|
      unless existing_suggested_articles.include? s.article
        existing_suggested_articles.push s.article
      end
    end

    #out of all of the recent_articles, grab the onces that don't already exist in the Topic or in the Topic's Suggestions
    all_recent_articles.each do |a|
        #Resource
      if topic.resources.include? a.resource
        #create suggestions
        unless existing_suggested_articles.include? a or existing_topic_articles.include? a #here is where we filter the above
          new_suggestion = topic.suggestions.build(:reason => "Resource", :evidence => a.resource.title)
          new_suggestion.article = a
          new_suggestion.save
        end
      else
        #Keyword
        topic.keywords.each do |k|
          # see if the keyword exists in in the article's desc or title
          if a.title.include? k.downcase
            #create suggestion
            unless existing_suggested_articles.include? a or existing_topic_articles.include? a
              new_suggestion = topic.suggestions.build(:reason => "Keyword", :evidence => k)
              new_suggestion.article = a
              new_suggestion.save
            end

          elsif a.desc.include? k.downcase
            #create suggestion
            unless existing_suggested_articles.include? a or existing_topic_articles.include? a
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
    count = 0
    topic.suggestions.each do |s|
      unless s.rejected == true
        count += 1
      end
    end
    present count # what if it displays a accepted suggestion. IMPOSSIBLE, these are deleted because they were added to the topic.articles. See Below
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
