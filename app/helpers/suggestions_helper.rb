module SuggestionsHelper


  def create_suggestions_for_topic(topic)
    remove_accepted_suggestions(topic)
    x_days = 3
    all_recent_articles = Article.where('article_date > ?', x_days.days.ago).where("publish_it != ? OR publish_it IS NULL",false) #test, not working with scope

    existing_suggested_articles = [] # get existing suggestions
    existing_topic_articles = topic.articles.where('article_date > ?', x_days.days.ago) # get recent articles from topic

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
        #USING TAGS FOR KEYWORDS, BECAUSE ARRAYS ARE FUCKED IN RAILS 4/22
        topic.tags.each do |keyword|
          # see if the keyword exists in in the article's desc or title
          k = keyword.title
          if a.title.downcase.include? k.downcase
            #create suggestion
            unless existing_suggested_articles.include? a or existing_topic_articles.include? a
              new_suggestion = topic.suggestions.build(:reason => "Keyword", :evidence => k)
              new_suggestion.article = a
              new_suggestion.save
            end

          elsif a.desc.downcase.include? k.downcase
            #create suggestion
            unless existing_suggested_articles.include? a or existing_topic_articles.include? a
              new_suggestion = topic.suggestions.build(:reason => "Keyword", :evidence => k)
              new_suggestion.article = a
              new_suggestion.save
            end
          else
            article_tags = []
            a.tags.each do |tag|
              # add tag title to article_tags
              article_tags.push tag.title.downcase
            end

            if article_tags.include? k.downcase
              # article's tag contains keyword, create suggestion
              new_suggestion = topic.suggestions.build(:reason => "Tag", :evidence => k)
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
    sauerAI(topic)
    count = 0
    topic.suggestions.each do |s|
      if s.article
        unless s.rejected == true or s.article.publish_it == false
          count += 1
        end
      end
    end
    present count # what if it displays an accepted suggestion. IMPOSSIBLE, these are deleted because they were added to the topic.articles. See Below
  end

  def remove_accepted_suggestions(topic)
    # if the topic contains this article, we want to remove the suggestion
    suggestions = []
    topic.suggestions.each do |s|
      # get article suggestions
      if topic.articles.include? s.article
        # remove the suggestion
        if s.auto_publishing
          s.auto_publishing.delete
        end
        s.auto_publishing = nil
        s.save
        s.delete # WE DON'T NEED TO KEEP A SUGGESTION IF IT WAS ACCEPTED
      end
    end
  end


  def accept_all_suggestions_for(topic)
    suggestions = topic.suggestions.where('rejected IS ?', nil)

    suggestions.each do |s|
      # accept suggested article and publish it
      s.article.publish_it = true
      unless s.article.topics.include? topic
        s.article.topics.push topic
      end
      s.article.save
      s.rejected = false
      s.save
    end
    present "Successfully accepted all suggestions"
  end


  def add_content_to_new_topic(topic)
    # run in terminal, set the keywords of the topic first
    topic.tags.each do |keyword|
      k = keyword.title.downcase
      # search for tags with this title
      t = Tag.where(:title => k).first
      if t #if the tag exists
        # grab all of the articles with this tag and add them to the topics articles
        t.articles.each do |a|
          unless topic.articles.include? a
            topic.articles.push a
          end
        end
      end
    end
  end



  def sauerAI(topic)
    #sauer automatically adds suggested articles to there respected articles
    # if and when sauer is sure, he has the privlege to accept articles that have not already been accept
    # by no means does sauer have the authority to reject an article (written April 4, 2017)

    # running in the count_suggested_articles_of_topic()

    # given the topic, sauer will explore it's attributes and decide whether a particular article fits it's standards

    number_rejects = 0
    number_accepts = 0
    new_suggestions = topic.suggestions.where("rejected IS ?", nil)
    new_suggestions.each do |s|
      # determine whether this article fits the topic

      if s.article
        #article exists, now validate that is fits the topic
        resource = s.article.resource

        #automatic admission (70% or above)
        rataitt = 0.0 # number of resource articles that are in the topic

        resource.articles.each do |a|
          #check and add to rataitt
          if a.topics.include? topic
            # add one to rataitt
            rataitt += 1.0
          end
        end

        percent = rataitt / resource.articles.count

        if percent >= 0.7
          # automatic admission, accept and add the article to this topic
          # if article was rejected, do not change
          number_accepts += 1

          accept_suggestion(s, topic)
          puts percent
        else
          # Reliabilty Test + History(use percent / 2 from above code)
          part_1 = percent / 2 # 0% - 50%
          part_2 = resource_reliability_score(resource, topic) # returns 0 - 50%

          percent_2 = part_2 + part_1

          if percent_2 > 0.69
            # accept suggestion  , (both are automatic if you think about it)
            accept_suggestion(s, topic)
            puts percent_2
            number_accepts += 1
          else
            puts "Rejected Article"
            puts percent_2
            number_rejects += 1
          end

        end

      end
    end

    puts "Number of accepted suggestions #{number_accepts}"
    puts "Number of rejected suggestions #{number_rejects}"

  end


  def accept_suggestion(s, topic)
    #using topic and suggestion, add the article into the topics
    # if article was rejected, do not change

    if s.article
      unless s.article.publish_it == false
        #article exists and wasn't rejected, add to the topic
        article = s.article

        article.publish_it = true # we set it to true because it could have been nil before
        article.save
        unless article.topics.include? topic
          #add topic
          article.topics.push(topic)
        end
        # accept the suggestion
        s.rejected = false
        s.save
      end
    end
    puts "Accepted Article"
  end


  def resource_reliability_score(resource, topic)
    score = 0.0 # out of fifty percent

    # does resource have topic
    if resource.topics.include? topic
      # add 25% to score
      score = 0.25
    end

    accepted = resource.articles.where(:publish_it => true).count
    ratio = (accepted * 1.0) / (resource.articles.count * 1.0)

    if ratio > 0
      #convert to percentage
      ratio_converted = ratio / 4 #0 - 25%
      score += ratio_converted
    end

    return score
  end





  def delete_duplicates
    # delete the articles that appear twice
    #find articles with same url, delete one
    articles = Article.all

    removing = []
    count = 0 # count duplicates
    articles.each do |a|
      # look for double
      if articles.where(:article_url => a.article_url).where("publish_it IS ?", nil).count > 1

        removing.push articles.where(:article_url => a.article_url).where("publish_it IS ?", nil).first
        count += articles.where(:article_url => a.article_url).where("publish_it IS ?", nil).count
      end
    end

    removing.each do |r|
      r.suggestions.clear
      r.delete
    end

    puts count
    puts removing.count
  end



end
