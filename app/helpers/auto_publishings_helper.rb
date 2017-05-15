require 'open-uri'

module AutoPublishingsHelper


  def automatic_publishing(suggestion)
    # using a suggestion, determine whether the article is right for the topic

    #get sentences from article
    sentences = get_article_sentences suggestion.article.article_url

    # get proofs
    proofs = organize_topic_proofs suggestion.topic

    reasons = assess_proofs(proofs, sentences)

    if reasons.count > 0
      # set suggestion.rejected = false
      # create auto_publish to explain why article automatically published
      suggestion.rejected = false
      suggestion.save
      create_explaination(reasons, suggestion)
      publish_article(suggestion)
    end

  end


  def get_article_sentences(url)
    #returns array of sentences
    # splits Text by . ! ?
    #article is the text in the article
    html = Nokogiri::HTML(open(url)) # displays all text on url
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
          reasons.push reason
        end
      end
    end

    # if we have any reason for automatically publishing this article to this website, do it
    if reasons.count > 0
      # add topic to article's topic
      # create auto_publish to explain why article automatically published
      # this is done on the top func
    else
      p "no reason to add this topic"
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

end
