require 'open-uri'
require 'hangry'

class RecipeIngredientsController < ApplicationController
  before_action :set_recipe_ingredient, only: [:show, :edit, :update, :destroy]

  # GET /recipe_ingredients
  # GET /recipe_ingredients.json
  def index
    @recipe_ingredients = RecipeIngredient.all

    url = "http://namelymarly.com/easy-vegan-chocolate-croissants-raspberries/"#"http://minimalistbaker.com/grain-free-tabbouleh-salad-6-ingredients/" #https://smittenkitchen.com/2017/03/mushroom-tartines/
    site = Nokogiri::HTML(open(url)) # this is the website source code

    # p site

    p "#{site}".length
    tyt = """If using whole coriander, cumin seeds, and black peppercorns, add to a small skillet and toast over medium-low heat for 4-5 minutes, shaking / stirring occasionally, or until fragrant and slightly deeper in color. Be careful not to burn! If using powder, skip this step. Once seeds are toasted, add to a mortar and pestle and loosely crush. If you don't have a mortar and pestle, slightly cool the seeds, add them to a sandwich bag, and crush with a rolling pin or a heavy pan. Set aside. To a food processor (or blender with a narrow base), add green chilies, bell pepper, garlic, lemongrass, ginger, green onions (or shallot), coriander, cumin, black pepper, turmeric, sea salt, lemon juice, lime zest + juice, oil / water, and maple syrup (or other sweetener). Blend / mix until a paste forms, scraping sides down as needed. The lemongrass can be difficult to grind at first, but give it time! It's fine. Taste and adjust flavor as needed, adding more lime zest or juice for acidity, salt for saltiness, chilies for heat, maple syrup for sweetness, oil (or water) for creaminess, garlic for zing, ginger for brightness, or turmeric for more intense curry flavor. Store curry paste in a jar in the refrigerator up to 10 days or more. For longer storage, transfer paste to an ice cube tray, freeze, then store in a freezer-safe bag up to 1 month. This curry paste is ideal for curries, soups, sauces, salad dressings, and more!"""
    @it = convert_instructions2("#{site}", url)

    # @it = found_sentence("o a large mixing bowl, add pa", url)

  end


# First Conversion approach,
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
