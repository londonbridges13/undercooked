require 'open-uri'

module RecipeIngredientsHelper


  def convert_instructions2(html, url)
    p html.length


    # first check if possible
    if check_if_possible(html, ">Ingredients<")

      #Continue...
      # Get starting point
      starting_point = get_starting_point(">Ingredients<", html)
      if starting_point

        #Continue...
        # Crop Instructions
        site = Nokogiri::HTML(open(url))
        rehtml = "#{site}"

        cropped_instructions = locate_ul_ol(rehtml, starting_point)
        if cropped_instructions #end_point
          p cropped_instructions
          #Continue...
          array_instructions = group_instructions(cropped_instructions) #didn't use the gap tags
          if array_instructions.count > 0
            #create an Instruction for each
            p "success... #{array_instructions}"
            p array_instructions.last  #not done, just testing
            p array_instructions.first  #not done, just testing
            p array_instructions.second  #not done, just testing

          else
            p "no instructions found after group_instructions"
          end
        else
          "Couldn't crop instructions"
        end
      else
        puts "Couldn't find the starting point"
      end
    else
      puts "Not possible"
      p "May have multiple recipes (and therefore multiple instructions)"
    end

  end

  def check_if_possible(html, keyword)
    # must return bool
    if count_ap(html, keyword) == 1
      return true
    else
      return false
    end
  end


  def get_starting_point(keyword, html)
    # keyword should be ">Instructions<"
    #return index after ">Instructions<"

    o_tags = find_all_possible_indexes(html, "<") #opening tags
    c_tags = find_all_possible_indexes(html, ">") #closing tags

    # if the lowest index for > is lower than the lowest index for <, then the find_text must must remove everything
    # before it
    lowest_c = c_tags.min
    lowest_o = o_tags.min
    if lowest_c and lowest_o
      if lowest_c < lowest_o
        # remove everything before the >
        new_text = find_text[lowest_c + 1...html.length - 1]
        html = new_text
        c_tags.remove(lowest_c)
      end
    end

    # Above removed all before ">" (including ">")

    # Now find keyword

    starting_point = html.index(keyword) # idk if this works

    return starting_point
  end


  # def find_all_tags(starting_point, html)
  #   #return array of tags. "<...>"
  #
  #   tags = []
  #
  #   while html.include? "<"
  #     # remove tag then remove < and >
  #     index1 = html.index("<")
  #     index2 = html.index(">")
  #     if index1 < index2
  #       # Remove all this ( thru )
  #       tag = html[index1...index2 + 1]
  #       html.slice! tag # everything < thru > was removed, it must remove or it would be infinte
  #       tags.push tag
  #     end
  #   end
  #
  #   return tags
  # end




  # def find_text_between_tags(instructions, html)
  #   #return array of text. >"..."<
  #
  #   text_array = []
  #
  #   while html.include? "<" and html.include? ">"
  #     # remove tag then remove < and >
  #     index1 = html.index("<")
  #     index2 = html.index(">")
  #     if index1 > index2 #great continue
  #       # Remove all this ( thru )
  #       text = html[index2 + 1...index1]
  #       html.slice! html[0...index1] # everything up to "<" was removed
  #       text_array.push text
  #     else
  #       #this should happen before the top every time, the first time
  #       # remove all the way up to the first ">" (not including ">")
  #       html.slice! html[0...index2] # everything up to ">" was removed
  #     end
  #   end
  #
  #   return text_array
  #
  # end


  def locate_ul_ol(html, sp)
    # locate the instructions, it is capped by the <ul> or <ol>
    # return cropped instructions, then run group_instructions (outside)

    test_html = html[sp...sp + 80] # check here for the ul or ol
    p test_html
    p "test_html"

    if test_html.include? "<ul"
      # grab <ol to </ol>
      html.slice! html[0...sp] # remove the begining
      si = html.index("<ul")
      ei = html.index("</ul") #may come into problems with mini recipes
      if si and ei
        cropped_instructions = html[si...ei]
        return cropped_instructions
      end
    elsif test_html.include? "<ol"
      # grab <ul to </ul>
      html.slice! html[0...sp] # remove the begining
      si = html.index("<ol")
      ei = html.index("</ol") #may come into problems with mini recipes
      if si and ei
        cropped_instructions = html[si...ei]
        return cropped_instructions
      end
    else
      p "didn't locate ul or ol"
    end
  end

  def grab_gap_tags(sp, ep, html)
    #return tags from the instructions

    # there is one more step then gap

    gap_keys = ["li"]
    ci = html[sp...ep] #cropped_instructions

    tags = []
    while ci.include? "<"
      # remove tag then remove < and >
      index1 = ci.index("<")
      index2 = ci.index(">")
      if index1 < index2
        # Remove all this ( thru )
        tag = ci[index1...index2 + 1]
        ci.slice! tag # everything < thru > was removed, it must remove or it would be infinte
        if tag.include? "li" # only gap tab
          tags.push tag
        end
      end
    end

    return tags
  end


  def group_instructions(cropped_html) # cropped html
    # from the gap_tags in the html, grab the inbewteen text before it, search for that in the
    # cropped_instructions. When found, add to array of instructions and delete that part in the grouped instructions
    # If unable to find, trim the edges (remove the first and last character), and search again
    p "starting group_instructions"
    li = "<li"
    cli = "</li"
    instructions = []

    while cropped_html.include? li
      p cropped_html
      #clear to "<li"
      if cropped_html.include? li
        li_index = cropped_html.index(li)
        # cropped_html.slice! cropped_html[0...li_index] # everything up to "<li" was removed

        # XXXnow remove to ">" end of the opening li, instructions on the otherside
        # group the li> ... </li
        # c = ">"
        cli_index = cropped_html.index(cli)
        # cropped_html.slice! cropped_html[0...cli_index + 1] # everything up to ">" was removed (including >)

        if li_index and cli_index
          p " li_index and cli_index"
          #clear tags, push to instructions
          i = cropped_html[li_index...cli_index]
          instructions.push clear_inner_tags(i)
          cropped_html.slice! cropped_html[0...cli_index + 1]
        elsif li_index
          p "li_index"
          # go for li_index to the end
          i = cropped_html[li_index...cropped_html.length + 1]
          instructions.push clear_inner_tags(i)
          cropped_html = ""
        end

      else
        p "cropped_html"
        cropped_html = "" # we are done
      end

      # while statement is over
      # return instructions
    end

    p "instructions"
    p instructions
    return instructions


  end


  def clear_inner_tags(i)
    #return instruction
    p "clear_inner_tags"
    rebuilt_i = ""

    # if i.include? "<"
    #   rebuilt_i = i[0...i.index("<")] # grab all that comes befor the t
    # end
    # don't need because it starts with li tag

    if i.include? ">" or i.include? "<"
      p "i.include? > or i.include? <"
      while i.include? ">" or i.include? "<"
        p "while i.include? > or i.include? <"
        if i.include? ">" and i.include? "<"
          p "i.include? > and i.include? <"
          if i.index(">") < i.index("<")
            p "i.index(>) < i.index(<)"
            # > comes before <
            i.slice! i[0...i.index(">") + 1]
            part_i = i[0...i.index("<")]
            rebuilt_i = rebuilt_i + part_i

            #slice afterwards
            i.slice! i[0...i.index("<")]
          else
            p "else"
            # remove < to >

            i.slice! i[i.index("<")...i.index(">") + 1]
            p i # PERFECT
            # get new index, if possible
            new_index = i.index("<")
            if new_index
              part_i = i[0...new_index]
              rebuilt_i = rebuilt_i + part_i
              i.slice! i[0...new_index]
            else
              # can't find, your done
              part_i = i
              rebuilt_i = rebuilt_i + part_i
            end
          end
        elsif i.include? ">"
          p "elsif i.include? >"
          # grab anything after >
          c_index = i.index(">")

          part_i = i[c_index...i.length + 1]
          rebuilt_i = rebuilt_i + part_i

          i.slice! i[c_index...i.length + 1]
        elsif i.include? "<"
          #grab anything before <, then we are done
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
    p "rebuilt_i"

    return rebuilt_i
  end


  def count_ap(string, substring)
    string.scan(/(?=#{substring})/).count
  end

  def find_all_possible_indexes(string, substring)
    # return all indexes of string
    #like count_ap
    indexes = []#= string.scan(/(?=#{substring})/)
    string.scan(/a/) do |c|
      indexes << $~.offset(0)[0]
    end
    return indexes
  end


  def decipher(html, parse)
    #return time, name, or comment

    content = "" #what we'll be returning
    parse.each do |p|
      if html.include? p
        p_index = html.index(p)
        html.slice! html[0...p_index]
      end
    end

    lp_length = parse.last.length
    html.slice! html[0...lp_length]
    if html.include? "<"
      content = html[0...html.index("<")]
      return content
    end
  end


end
