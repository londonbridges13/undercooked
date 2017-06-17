require 'open-uri'
require 'open_uri_redirections'
require 'hangry'

class ContentWorker
  include SuckerPunch::Job
  workers 1

  def perform(none)
    ActiveRecord::Base.connection_pool.with_connection do
      channels = Resource.all
      @cm = ContentManagement.first
      @count = 0
      a_day_ago = Time.now - 1.day
      if a_day_ago > @cm.updated_at
        channels.each do |channel|
          if channel
            puts "Checking for new articles"
            find_new_articles_from_channel(channel)
            # channel.suggestions.each do |s| # with channel its not possible
            #   # assess suggestions
            #   p "Assessing Suggestion: #{s.id}"
            #   # automatic_publishing s
            # end
            @count += 1
          else
            puts "No Topic"
          end
        end
        # done with search, update ContentManagement time
        if @count >= channels.count
          @cm.last_new_article_grab_date = "#{Time.now}"
          @cm.save
          create_and_accept_new_suggestions #automatic organizing
        else
          puts "All Topics are not acounted for. We only got #{@count}. Did not save the Content Management. Will try job again!"
        end

      else
        puts "Checked in last 24 hours"
      end
    end
  end




    #Get New Articles
      def find_new_articles_from_topic(topic)
        #This grabs new articles from one topic
        #Take all the resources from the topic and searches them for new articles
        topic.resources.each do |r|
          check_resource(r)
        end
      end

      def find_new_articles_from_channel(channel)
          check_resource(channel)
      end

      def get_all_channel_articles
        Resource.all.each do |r|
          find_new_articles_from_channel r
        end
      end

      def check_resource(resource) #should be the same as ArticlesHelper
        if resource.resource_type == "error"
          #do nothing
          puts "This resoruce has it's own error"
        elsif resource.resource_type == "article-xml" #or resource.resource_url.include? "autoimmunewellness.com"
          # the weird articles that cause errors
          get_other_articles(resource)
        elsif resource.resource_url.include? "youtube.com" or resource.resource_type == "video"
          # Check for videos in this resource
          get_youtube_videos(resource)
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
        #xml = Faraday.get(url).body.force_encoding('utf-8')
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
                article_image_url = LinkThumbnailer.generate(entry.url).images.first.src.to_s
                # article_image_url = images.images.first.src.to_s

                #description
                video = VideoInfo.new(entry.url)
                description = ""
                if video
                  if video.description
                    description = video.description
                  end
                end
                new_article = resource.articles.build(:title => entry.title, :article_url => entry.url, :article_image_url => article_image_url,
                :desc => description, :resource_type => 'video', :article_date => entry.published, :publish_it => nil)#, :image)
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
                if LinkThumbnailer.generate(entry.url, attributes: [:images], image_limit: 1, image_stats: false).images.first
                  article_image_url = LinkThumbnailer.generate(entry.url, attributes: [:images], image_limit: 1, image_stats: false).images.first.src.to_s
                end
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



    # Check for Recipe inside the new article (Conversion). If possible then convert the recipe

    # Functions for conversion
    def ingredient_has_number_before_slash(ingredient)
      # solve for
      # 1 1/2 pounds (680 grams) fresh mushrooms

      # ingreedy may already solve for this
    end

    def ingredient_has_dash_before_number(ingredient)
      # solve for
      # 3-6 Tbsp (45-90 ml) vegetable broth

      #ingreedy does
      #amount: 3
      #unit: nil
      #ingredient: -6 Tbsp (45-90 ml) vegetable broth
      # we don't want the "-6" in the ingredient

      # we want
      #amount: 3
      #unit: tablespoon
      #ingredient: vegetable broth

      # Remove "-" if it is in the first 5 characters
      # Remove number if it was touching dash or next to dash. ex: "-6" or "- 6"

      numbers = ['1','2','3','4','5','6','7','8','9','10',
        'one','two','three','four','five','six','seven','eight','nine','ten']

      # Check for each digit
      numbers.each do |n|
        if ingredient[0...5].include? "-" and ingredient.include? n #n is number
          #has - in the first six characters
          #might have number next to dash

          if ingredient.include? "-"+n
            # remove this
            ingredient.slice! "-"+n
          elsif ingredient.include? "-"+" "+n
            # remove this
            ingredient.slice! "-"+" "+n
          end
        end
      end

      # Continuing...
      # if there is no unit, add the amount back to the pry_ingredient (in this case ingredient) and run Ingreedy on it
      # Why?
      # Because this might get the unit

      return ingredient
    end


    def remove_parenthesis(ingredient)
      # solve for
      # 3-6 Tbsp (45-90 ml) vegetable broth

      #ingreedy does
      #amount: 3
      #unit: nil
      #ingredient: -6 Tbsp (45-90 ml) vegetable broth
      # we don't want the "(45-90 ml)" in the ingredient

      # we want
      #amount: 3
      #unit: tablespoon
      #ingredient: vegetable broth

      #Remove "(" thru ")" if it contains numbers

      numbers = ['1','2','3','4','5','6','7','8','9','10',
        'one','two','three','four','five','six','seven','eight','nine','ten']


      numbers.each do |n|
        if ingredient.include? "(" and ingredient.include? ")" and ingredient.include? n #n is number
          # this may have a number between the parenthesis
          #First locate the index of "(", then ")"
          # then check if the ingredient[index1...index2].include? n

          index1 = ingredient.index("(")
          index2 = ingredient.index(")")

          if ingredient[index1...index2 + 1].include? n
            # Remove all this ( thru )
            removable = ingredient[index1...index2 + 1]
            ingredient.slice! removable # everything ( thru ) was removed
          end
          #DONE
        end
      end

      return ingredient
    end


    def ingredient_conversion(i)

        # convert and save this ingredient
        # first clean off the ingredient
        ingredient = i # one ingredient conversion approach

        pry_ingredient = ingredient # use this to cut off the unit, amount, and ingredient

        pry_ingredient = ingredient_has_dash_before_number(pry_ingredient)
        pry_ingredient = remove_parenthesis(pry_ingredient)

        ingredient = Ingreedy.parse(pry_ingredient) # one ingredient conversion approach


        if ingredient.ingredient
          # then we have what we need
          # find/create in ingredient
          # create new recipe_ingredient linking the recipe to that ingredient

          amount = 0

          if ingredient.amount
            amount = ingredient.amount.to_r.to_f#x / y
          end

          get_ingredient = Ingredient.find_or_create_by(title: ingredient.ingredient)
          new_recipe_ingredient = Recipe_Ingredient.new(amount: amount, unit: ingredient.unit) # if possible
          new_recipe_ingredient.ingredient = get_ingredient
          new_recipe_ingredient.recipe = new_recipe

        else
          #custom ingredient conversion
          puts "Using Custom Ingredient Conversion. Not Done"

          # Keep in mind...
          # The ingredient may not have an amount or unit (of measurement)

          # try and solve for
          # 1 1/2 pounds (680 grams) fresh mushrooms (cremini, white or a mix of wild all work), thinly sliced
          # this is real, from https://smittenkitchen.com/2017/03/mushroom-tartines/

          # keywords to look out for
          units_of_measurement = ['oz','cup','slice','floz','fl oz','ml','g','grams','gram',
            'lbs','lb','pounds','pound','piece','pieces','teaspoons','teaspoon',
            'tablespoon','tablespoons']

          unit = "" #use as ingredient.unit
          units_of_measurement.each do |m|
            measurement = " "+m+" "
            if i.include? measurement
              #found a unit of measurement
              #set as ingredient.unit
              unit = m
            end
          end

          # seperate ingredients with / from the others.
          # These most likely include numbers (amount) ex: 1 1/2 pounds (680 grams) fresh mushrooms
          # I believe they already solve for this


          #Retry with the Ingreedy
          ingredient = Ingreedy.parse(pry_ingredient) # one ingredient conversion approach


          #now find the amount, if possible
          amount = 0
          numbers.each do |n|
            if pry_ingredient.include? n
              # then it has a number (amount)
              # set ingredient.amount
            end
          end


          #now find the ingredient


        end
    end

    def convert_instructions(instructions, url)
      # scrap the url webpage
      # find the instructions
      # find the simliarities in the structure of the instructions
      # then group the instructions in that manner

      # Why?
      # Because some instructions have more than one sentence in them

      # Why not just split them be the sentence? ex: "."
      # We don't want to make the recipe seem longer than it is.
      # A recipe with 6 instructions may look like a recipe with 16 instructions when spliting by the "."


      first_step = ""
      last_step = ""

      # Grab the first step, first sentence
      #Grab first sentence
      if i[0...20].include? "."
        # the sentence is short, go with the first "."
        #find index of "."

        p_index = i.index(".") # index of first period

        if p_index > 10
          #This is good, it means that the sentence isn't short, continue
          first_step = i[0...p_index] #search for this sentence
        else
          #this is a short sentence, use a different sentence

        end
      end

      # Grab the last sentence

      lp_index = i.length
      starting_index = lp_index - 15

      last_sentence = i[starting_index...lp_index]

      unless found_sentence(last_sentence, url)
        # this is all apart of the last step
        last_step = last_sentence
      else
        # all of this is not apart of the last step
        # choose another range
        retry_last_sentence_index = last_sentence.index(".")

        if retry_last_sentence_index > 7
          # choose the part afterwards a
          retry_last_sentence = last_sentence[retry_last_sentence_index...lp_index]
          if found_sentence(retry_last_sentence, url) # returns bool
            last_step = retry_last_sentence
          end
        else
          retry_last_sentence = last_sentence[starting_index...retry_last_sentence_index]
          if found_sentence(retry_last_sentence, url)# returns bool
            last_step = retry_last_sentence
          end
        end
      end


      found_sentence(last_step, url)
      found_sentence(first_step, url)

      if found_sentence(last_step, url) and found_sentence(first_step, url)
        pry_instructions = grab_two_sentences(first_step, last_step, url)
      end

    end


    def found_sentence(sentence, url)
      # use Nokogiri to find sentence in the web script

      site = Nokogiri::HTML(open(url, :allow_redirections => :safe)) # this is the website source code

      if site.include? sentence
        return true
      else
        return false
      end

    end


    def grab_two_sentences(first_step, last_step, url)
      # grab all the instructions between the first and last

      site = Nokogiri::HTML(open(url, :allow_redirections => :safe)) # this is the website source code

      # grab the index of the first and last step
      f_index = site.index(first_step)
      l_index = site.index(last_step)

      #the last step should have a higher index
      if l_index > f_index
        # Great, continue
        pry_instructions = site[f_index...l_index]
        return pry_instructions
      else
        # there is a big problem here

      end

    end



    def convert_article(article)
      #  If possible, then convert the recipe
      #grab the url of the article
      url = article.article_url

      if url
        #continue with conversion
        # first attempt with hangry
        hangry_conversion(article)
      end

    end


    def hangry_conversion(article)
      #  If possible, then convert the recipe
      ingredients = []

      # convert here
      recipe_html_string = open(article.article_url, :allow_redirections => :safe).read
      recipe = Hangry.parse(recipe_html_string)

      recipe.author         # "Rachel Ray"
      recipe.cook_time      # 20
      recipe.description    # nil
      recipe.image_url      # "http://img.foodnetwork.com/FOOD/2008/08/13/av-rachael-ray.jpg"
      recipe.ingredients    # ["4 boneless, skinless chicken breasts, 6 ounces", "Large plastic food storage bags or waxed paper", "1 package, 10 ounces, frozen chopped spinach", "2 tablespoons butter", "12 small mushroom caps, crimini or button", "2 cloves garlic, cracked", "1 small shallot, quartered", "Salt and freshly ground black pepper", "1 cup part skim ricotta cheese", "1/2 cup grated Parmigiano or Romano, a couple of handfuls", "1/2 teaspoon fresh grated or ground nutmeg", "Toothpicks", "2 tablespoons extra-virgin olive oil", "2 tablespoons butter", "2 tablespoons flour", "1/2 cup white wine", "1 cup chicken broth"]
      recipe.instructions   # "Place breasts in the center of a plastic food storage..."
      recipe.name           # "Spinach and Mushroom Stuffed Chicken Breasts"
      recipe.prep_time      # 15
      # recipe.published_date # #<Date: 2013-02-06 >
      recipe.total_time     # 35
      recipe.yield          # "4 servings"


      # create new recipe
      new_recipe = Recipe.new

      new_recipe.author = recipe.author
      new_recipe.cooktime = recipe.cook_time
      new_recipe.description = recipe.description
      new_recipe.title = recipe.name
      new_recipe.prep_time = recipe.prep_time
      # recipe.published_date #
      new_recipe.total_time = recipe.total_time
      new_recipe.serving_size = recipe.yield

      instructions = recipe.instructions
      recipe_ingredients = recipe.ingredients


      #gather ingredients
      recipe_ingredients.each do |i|
        ingredient_conversion(i)
      end


      #gather instructions
      instructions = recipe.instructions



      puts ingredients.count
      if new_recipe.ingredients.count >= 2 and new_recipe.ingredients.count <= 50 and new_recipe.instructions.count >= 2 and new_recipe.instructions.count <= 50
        #Successful conversion lets save the new recipe


      else
        # unsuccessful attempt, lets try again

      end

    end



    def second_conversion(article)
      #  If possible, then convert the recipe
      ingredients = []

      # convert here


      puts ingredients.count
      if ingredients.count >= 2 and ingredients.count <= 50
        #Successful conversion lets check it out.

      else
        # unsuccessful attempt, lets try again

      end

    end



    # def next_conversion(article)
    #   #  If possible, then convert the recipe
    #   ingredients = []
    #
    #   # convert here
    #
    #
    #   puts ingredients.count
    #   if ingredients.count >= 2 and ingredients.count <= 50
    #     #Successful conversion lets check it out.
    #
    #   else
    #     # unsuccessful attempt, lets try again
    #
    #   end
    #
    # end


# Automatic Publishing

    def automatic_publishing(suggestion)
      # using a suggestion, determine whether the article is right for the topic

      #get sentences from article
      sentences = get_article_sentences suggestion.article.article_url

      # get proofs
      proofs = organize_topic_proofs suggestion.topic

      if sentences and proofs
        reasons = assess_proofs(proofs, sentences)

        if reasons
          if reasons.length > 0
            # set suggestion.rejected = false
            # create auto_publish to explain why article automatically published
            suggestion.rejected = false
            suggestion.save
            create_explaination(reasons, suggestion)
            publish_article(suggestion)
          end
        end
      end

    end


    def get_article_sentences(url)
      #returns array of sentences
      # splits Text by . ! ?
      #article is the text in the article
      html = Nokogiri::HTML(open(url, :allow_redirections => :safe)) # displays all text on url
      article = "#{html}"
      start = article.index("<article")
      ending = article.index("</article")
      if start and ending
        cropped_article = article[start...ending]
        cropped_article = clear_inner_tags(cropped_article)

        sentences = cropped_article.scan(/[^\.!?]+[\.!?]/).map(&:strip)
        return sentences
      else
        p "Unable to crop article, parse the whole url?"
        p "No, not yet developed"
        return nil
      end
    end

    def organize_topic_proofs(topic)
      #return proofs (an array of arrays of strings (ALL DOWNCASED))
      # [["no", "gluten"], ["gluten-free"], ["gluten", "free"]]

      # take array of proofs and split them by the "~" to get the keywords in the array
      proofs = []
      ap = topic.auto_proofs
      ap.each do |pp|
        # organize into proof array
        # split by "~"
        pp.downcase!
        if pp.include? "~"
          # Split by ~
          array = []
          while pp.include? "~"
            index = pp.index("~")
            part = pp[0...index]
            array.push part
            pp.slice! pp[0...index + 1]
          end
          array.push pp[0...pp.length]
          proofs.push array
        else
          # doesn't contain ~
          array = []
          array.push pp
          proofs.push array
        end
      end
      return proofs
    end


    def assess_proofs(proofs, sentences)
      # check each proof to see if the sentence contains the proof in it
      # return reason array

      reasons = ""

      sentences.each do |s|
        proofs.each do |e|
          # see if e (array) is in s (sentence)
          array = e # e hold an array of keywords, find all keywords in sentences

          count = 0
          pass = array.count # if the count == pass after the loop below, then it contains all the keywords and it passed
          array.each do |a|
            if s.include? a
              count += 1
            end
          end

          if count == pass
            # sentence contains all keys in proof, automatically publish and create reason
            reason = create_reason(e)
            if reason and reason != ""
              reasons.push reason
            end
          end
        end
      end

      # if we have any reason for automatically publishing this article to this website, do it
      if reasons
        if reasons.length > 10
          # add topic to article's topic
          # create auto_publish to explain why article automatically published
          # this is done on the top func
        else
          p "no reason to add this topic"
        end
      end

      return reasons
    end

    def create_reason(proof)
      # return elegant response (string)
      reason = "A sentence in this article contained these keywords: #{proof}."

      previous_word = ""
      proof.each do |e|
        if previous_word == ""
          # this is the first word set as first word
          previous_word = e
        else
          # create aloborate sentence
          part = " '#{previous_word.capitalize}' appearing before '#{e}'."
          reason = reason + part
        end
      end
      return reason
    end


    def create_explaination(reasons, suggestion)
      ap = AutoPublishing.find_or_create_by(:suggestion => suggestion)
      ap.reasons = reasons
      unless suggestion.auto_publishing
        ap.suggestion = suggestion
        ap.save
      end
      return ap
    end

    def publish_article(suggestion)
      suggestion.article.publish_it = true
      unless suggestion.article.topics.include? suggestion.topic
        suggestion.article.topics.push suggestion.topic
      end
      suggestion.article.save

    end

    def clear_inner_tags(i)
      rebuilt_i = ""
      if i.include? ">" or i.include? "<"
        while i.include? ">" or i.include? "<"
          if i.include? ">" and i.include? "<"
            if i.index(">") < i.index("<")
              i.slice! i[0...i.index(">") + 1]
              part_i = i[0...i.index("<")]
              rebuilt_i = rebuilt_i + part_i
              i.slice! i[0...i.index("<")]
            else
              i.slice! i[i.index("<")...i.index(">") + 1]
              new_index = i.index("<")
              if new_index
                part_i = i[0...new_index]
                rebuilt_i = rebuilt_i + part_i
                i.slice! i[0...new_index]
              else
                part_i = i
                rebuilt_i = rebuilt_i + part_i
              end
            end
          elsif i.include? ">"
            c_index = i.index(">")
            part_i = i[c_index...i.length + 1]
            rebuilt_i = rebuilt_i + part_i
            i.slice! i[c_index...i.length + 1]
          elsif i.include? "<"
            o_index = i.index("<")
            part_i = i[0...o_index]
            rebuilt_i = rebuilt_i + part_i
            i = ""
          end
        end
      else
        rebuilt_i = i
      end
      p rebuilt_i.gsub! /\t/, '' # removing tabs (namely marly)
      return rebuilt_i
    end



    def get_video_description(content)
      video = VideoInfo.new(content.article_url)
      if video
        if video.description
          p  video.description
          content.desc = video.description
          content.save
        end
      end
    end



    def create_suggestions_for_topic(topic)
      # remove_accepted_suggestions(topic)
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
      # count_suggested_articles_of_topic(topic)
      accept_all_suggestions_for topic
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
      # present "Successfully accepted all suggestions"
    end

    def create_and_accept_new_suggestions
      Topic.all.each do |t|
        create_suggestions_for_topic t
      end
    end



end
