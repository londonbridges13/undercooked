require 'open-uri'
require 'hangry'

class RecipeIngredientsController < ApplicationController
  before_action :set_recipe_ingredient, only: [:show, :edit, :update, :destroy]

  # GET /recipe_ingredients
  # GET /recipe_ingredients.json
  def index
    @recipe_ingredients = RecipeIngredient.all

    url = "http://minimalistbaker.com/easy-green-curry-paste/"#"http://sweetpotatosoul.com/2017/03/vegan-banana-french-toast-video.html"#"http://minimalistbaker.com/grain-free-tabbouleh-salad-6-ingredients/" #https://smittenkitchen.com/2017/03/mushroom-tartines/
    site = Nokogiri::HTML(open(url)) # this is the website source code

    # p site

    p "#{site}".length
    tyt = """If using whole coriander, cumin seeds, and black peppercorns, add to a small skillet and toast over medium-low heat for 4-5 minutes, shaking / stirring occasionally, or until fragrant and slightly deeper in color. Be careful not to burn! If using powder, skip this step. Once seeds are toasted, add to a mortar and pestle and loosely crush. If you don't have a mortar and pestle, slightly cool the seeds, add them to a sandwich bag, and crush with a rolling pin or a heavy pan. Set aside. To a food processor (or blender with a narrow base), add green chilies, bell pepper, garlic, lemongrass, ginger, green onions (or shallot), coriander, cumin, black pepper, turmeric, sea salt, lemon juice, lime zest + juice, oil / water, and maple syrup (or other sweetener). Blend / mix until a paste forms, scraping sides down as needed. The lemongrass can be difficult to grind at first, but give it time! It's fine. Taste and adjust flavor as needed, adding more lime zest or juice for acidity, salt for saltiness, chilies for heat, maple syrup for sweetness, oil (or water) for creaminess, garlic for zing, ginger for brightness, or turmeric for more intense curry flavor. Store curry paste in a jar in the refrigerator up to 10 days or more. For longer storage, transfer paste to an ice cube tray, freeze, then store in a freezer-safe bag up to 1 month. This curry paste is ideal for curries, soups, sauces, salad dressings, and more!"""
    @it = convert_instructions2(tyt, "#{site}", url)

    # @it = found_sentence("o a large mixing bowl, add pa", url)

  end

# New Conversion Approach

  def convert_instructions2(instructions, html, url)
    p html.length


    # first check if possible
    if check_if_possible(html, ">Instructions<")

      #Continue...
      # Get starting point
      starting_point = get_starting_point(">Instructions<", html)
      if starting_point
        #Continue...
        # grab last sentence
        last_sentence = get_last_instruction(instructions)
        if last_sentence
          #Continue...
          # Find all text between tags

          text_array = find_text_between_tags(instructions, html)
          if text_array.count > 0
            #Continue...
            # Crop Instructions
            site = Nokogiri::HTML(open(url))
            rehtml = "#{site}"

            # p rehtml.length
            # p html[2...1000]
            # p "???"
            # end_point = crop_instructions(last_sentence, text_array, rehtml) # this returns end_point
            cropped_instructions = locate_ul_ol(rehtml, starting_point)
            if cropped_instructions #end_point
              p cropped_instructions
              #Continue...
              array_instructions = group_instructions(cropped_instructions) #didn't use the gap tags
              if array_instructions.count > 0
                #create an Instruction for each
                p "success... #{array_instructions}"
                p array_instructions.last  #not done, just testing

              else
                p "no instructions found after group_instructions"
              end

              # Grab gap_tags
              # gap_tags = grab_gap_tags(starting_point, end_point, html)
              # if gap_tags.count > 0
              #   #Continue...
              #   # create array of instructions (groupped)
              #   array_instructions = group_instructions(html, gap_tags) #didn't use the gap tags
              #   if group_instructions.count > 0
              #     #create an Instruction for each
              #     p "success... #{group_instructions}"
              #     return group_instructions.first  #not done, just testing
              #
              #   else
              #     p "no instructions found after group_instructions"
              #   end
              # else
              #   p "Found no gap tags"
              # end
            else
              "Couldn't crop instructions"
            end
          else
            p "No text_array"
          end
        else
          puts "Couldn't get last instruction"
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


  def find_all_tags(starting_point, html)
    #return array of tags. "<...>"

    tags = []

    while html.include? "<"
      # remove tag then remove < and >
      index1 = html.index("<")
      index2 = html.index(">")
      if index1 < index2
        # Remove all this ( thru )
        tag = html[index1...index2 + 1]
        html.slice! tag # everything < thru > was removed, it must remove or it would be infinte
        tags.push tag
      end
    end

    return tags
  end


  def get_last_instruction(instructions)
    # Grab last sentence
    # or Grab last 30 characters
    # do both, then use(return) the bigger option

    option_1 = instructions[instructions.length - 30...instructions.length - 1] # last the 30 characters

    all_sentences = instructions.scan(/[^\.!?]+[\.!?]/).map(&:strip)
    option_2 = all_sentences[-1]

    p "all sentences: #{all_sentences}"
    p "Last sentence"
    p "#{option_1}"
    p "#{option_2}"

    if option_2 and option_1
      if option_1.length > option_2.length
        return option_1
      else
        return option_2
      end
    elsif option_2
      return option_2
    elsif option_1
      return option_1
    end
  end


  def find_text_between_tags(instructions, html)
    #return array of text. >"..."<

    text_array = []

    while html.include? "<" and html.include? ">"
      # remove tag then remove < and >
      index1 = html.index("<")
      index2 = html.index(">")
      if index1 > index2 #great continue
        # Remove all this ( thru )
        text = html[index2 + 1...index1]
        html.slice! html[0...index1] # everything up to "<" was removed
        text_array.push text
      else
        #this should happen before the top every time, the first time
        # remove all the way up to the first ">" (not including ">")
        html.slice! html[0...index2] # everything up to ">" was removed
      end
    end

    return text_array

  end


  def crop_instructions(last_sentence, text_array, html)
    #search the last_sentence for the text between tags
    # we know that the html text will fit in the instructions, we don't know if the instruction will fit in the html.
    # so we'll search the instruction (last_sentence) for the text between tags, to verify that it exists (and
    # crop the instructions)

    # thi will tell us when to stop, Because we will have entered the last sentenc.
    # All we want is to accurately group the sentence into instructions for the guide.

    #the last text (from the text_array) found will be used as an end point (end point of html)
    # return the end_point

    # Below it shows 15 a number of times, Why? Because we are searching for
    # the last text in the last_sentence (at least 30 char). if we can get 15 of the 30, chances are we are in the
    # right spot.

    last_text = "fake" # use for the last text found in text_array
    text_array.each do |text|
      p text
      if text.length > 15 and last_sentence.include? text
        if count_ap(html, text) == 1 # if this appear once it's good
          p "set #{text} for last_tast"
          last_text = text
        else
          p count_ap(html, text)
          p "To few or Too many"
        end
      else
        p "Too small a text"
      end
    end

    p last_text
    if last_text.length > 15
      # successfully found last text, return end_point
      if count_ap(html, last_text) == 1
        end_point = html.index(last_text)
        return end_point
      else
        # there are multiple occurances of this text, cannot convert
        puts "there are multiple occurances of this text, cannot convert "
        puts last_text
        puts last_sentence
        return nil
      end
    else
      p "Couldn't find a piece of the last sentence"
      p html.length
      return nil
    end

  end

  def locate_ul_ol(html, sp)
    # locate the instructions, it is capped by the <ul> or <ol>
    # return cropped instructions, then run group_instructions (outside)

    test_html = html[sp...sp + 50] # check here for the ul or ol
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
    p{instructions}
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
            p i
            # get new index, if possible
            new_index = i.index("<")
            if new_index
              part_i = i[0...new_index]
              rebuilt_i = rebuilt_i + part_i
              i.slice! i[0...new_index]
            else
              # can't find, your done
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
          o_index = i.index(">")

          part_i = i[0...o_index]
          rebuilt_i = rebuilt_i + part_i
          i = ""
        end
      end

    else
      rebuilt_i = i
    end

    p rebuilt_i
    return rebuilt_i
  end

# First Conversion approach
  def convert_instructions(i, url)
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
    last_sen_length = 40
    starting_index = lp_index - last_sen_length

    last_sentence = i[starting_index...lp_index]

    if found_sentence(last_sentence, url)
      # this is all apart of the last step
      last_step = last_sentence
    else
      # all of this is not apart of the last step
      # choose another range
      # retry_last_sentence_index = last_sentence.index(".")
      #
      # if retry_last_sentence_index > last_sen_length / 2
      #   # choose the part afterwards a
      #   retry_last_sentence = last_sentence[retry_last_sentence_index...lp_index]
      #   if found_sentence(retry_last_sentence, url) # returns bool
      #     last_step = retry_last_sentence
      #   end
      # else
      #   retry_last_sentence = last_sentence[starting_index...retry_last_sentence_index]
      #   if found_sentence(retry_last_sentence, url)# returns bool
      #     last_step = retry_last_sentence
      #   end
      # end
    end


    found_sentence(last_step, url)
    found_sentence(first_step, url)

    if found_sentence(last_step, url) and found_sentence(first_step, url)
      pry_instructions = grab_two_sentences(first_step, last_step, url)
      return pry_instructions
    end

  end


  def found_sentence(sentence, url)
    # use Nokogiri to find sentence in the web script

    site = Nokogiri::HTML(open(url)) # this is the website source code

    if site.inner_text.match(sentence)
      return true
    else
      return false
    end

  end


  def grab_two_sentences(first_step, last_step, url)
    # grab all the instructions between the first and last

    site = "#{Nokogiri::HTML(open(url)).inner_text}" # this is the website source code, it's the text (.inner_text)
    esite = Nokogiri::HTML(open(url)) # this is the website source code

    jsite = esite.inner_html # doesn't display article

    # grab the index of the first and last step
    f_index = "#{esite}".index(first_step)
    l_index = "#{esite}".index(last_step)

    # return esite #f_index #l_index

    #check the l_index and f_index

    unless l_index and l_index > 0
      l_index = mini_search(last_step, esite, "high")
    end

    unless f_index and f_index > 0
      f_index = mini_search(first_step, esite, "low")
    end

    return "#{l_index}" + "#{f_index}"
    #the last step should have a higher index
    if l_index > f_index
      # Great, continue
      pry_instructions = "#{esite}"[f_index...l_index]# + "#{f_index}" + "--"+ "#{l_index}"
      return first_step + "||" + last_step + "||" + pry_instructions
    else
      # there is a big problem here
      return "big problem"
    end

  end

  def mini_search(text, site, lowhigh)
    # split text in half, search for other half (make sure that the count_ap == 1, else validate, wait we are validating anyway)

    #split text
    part1 = text[0...text.length / 2]
    part2 = text[(text.length / 2) + 1...text.length - 1]

    # search for other half, if found use the return both indexes in array
    f_index = "#{site}".index(part1)
    l_index = "#{site}".index(part2)

    # indexes = []
    indexes = find_all_possible_indexes("#{site}", part2)

    have = find_all_possible_indexes("#{site}", part1)
    have.each do |i|
      indexes.push i
    end

    # we might want to run a loop for all indexes
    lowest = 99999999
    highest = 0

    indexes.each do |i|
        # then we have this part, validate with reach
        found = reach(i, text, "#{site}")

        if found == true
          #update lowest/highest to this valid index
          if i > highest
            highest = i
          end
          if i < lowest
            lowest = i
          end
        end
    end


    # do we want the highest index or the lowest? (Are we searching the very begining or the very end?)
    if lowhigh == "low"
      # we want the lowest index because we are searching for the beginning of the first sentence
      return lowest
    else
      #we are looking for the highest index because we are searching for the end of the last sentence
      return highest
    end
  end


  def reach(indexx, find_text, site)
    if indexx
      #from the index point reach out in both directions to find the text (find_text) inside of string (site)
      #if found return true else return false
      # reach out 20
      length = 30

      # remove <tags> from find_text, if any. Ther could be multiple tags
      o_tags = find_all_possible_indexes(find_text, "<") #opening tags
      c_tags = find_all_possible_indexes(find_text, ">") #closing tags

      # if the lowest index for > is lower than the lowest index for <, then the find_text must must remove everything
      # before it
      lowest_c = c_tags.min
      lowest_o = o_tags.min
      if lowest_c and lowest_o
        if lowest_c < lowest_o
          # remove everything before the >
          new_text = find_text[lowest_c + 1...find_text.length - 1]
          find_text = new_text
          c_tags.remove(lowest_c)
        end
      end

      # loop the remaining tag removal. we don't know if there are more then one
      while find_text.include? "<"
        # remove tag then remove < and >
        index1 = find_text.index("<")
        index2 = find_text.index(">")
        if index1 < index2
          # Remove all this ( thru )
          removable = find_text[index1...index2 + 1]
          find_text.slice! removable # everything < thru > was removed
        end

      end

      start = indexx - length
      ending = indexx + length
      range = site[start...ending]
      if range.include? find_text
        return true
      else
        return false
      end
    else
      #no indexx return false
      return false
    end
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


  # GET /recipe_ingredients/1
  # GET /recipe_ingredients/1.json
  def show
  end

  # GET /recipe_ingredients/new
  def new
    @recipe_ingredient = RecipeIngredient.new
  end

  # GET /recipe_ingredients/1/edit
  def edit
  end

  # POST /recipe_ingredients
  # POST /recipe_ingredients.json
  def create
    @recipe_ingredient = RecipeIngredient.new(recipe_ingredient_params)

    respond_to do |format|
      if @recipe_ingredient.save
        format.html { redirect_to @recipe_ingredient, notice: 'Recipe ingredient was successfully created.' }
        format.json { render :show, status: :created, location: @recipe_ingredient }
      else
        format.html { render :new }
        format.json { render json: @recipe_ingredient.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /recipe_ingredients/1
  # PATCH/PUT /recipe_ingredients/1.json
  def update
    respond_to do |format|
      if @recipe_ingredient.update(recipe_ingredient_params)
        format.html { redirect_to @recipe_ingredient, notice: 'Recipe ingredient was successfully updated.' }
        format.json { render :show, status: :ok, location: @recipe_ingredient }
      else
        format.html { render :edit }
        format.json { render json: @recipe_ingredient.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /recipe_ingredients/1
  # DELETE /recipe_ingredients/1.json
  def destroy
    @recipe_ingredient.destroy
    respond_to do |format|
      format.html { redirect_to recipe_ingredients_url, notice: 'Recipe ingredient was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_recipe_ingredient
      @recipe_ingredient = RecipeIngredient.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def recipe_ingredient_params
      params.require(:recipe_ingredient).permit(:amount)
    end
end
