require 'open-uri'
require 'hangry'

class RecipeIngredientsController < ApplicationController
  before_action :set_recipe_ingredient, only: [:show, :edit, :update, :destroy]

  # GET /recipe_ingredients
  # GET /recipe_ingredients.json
  def index
    @recipe_ingredients = RecipeIngredient.all

    url = "http://minimalistbaker.com/grain-free-tabbouleh-salad-6-ingredients/" #https://smittenkitchen.com/2017/03/mushroom-tartines/
    site = Nokogiri::HTML(open(url)) # this is the website source code

    @it = convert_instructions("To a large mixing bowl, add parsley, onion, and bell pepper. Top with lemon juice, olive oil, salt, and pepper and toss to combine. Add hemp seeds at this time if desired (optional). Taste and adjust flavor as needed, adding more lemon juice for acidity, salt and pepper for overall flavor, or olive oil if too dry. Serve immediately as a side for Mediterranean dishes like Mediterranean Baked Sweet Potatoes, Chickpea Shawarma Dip, or Chickpea Shawarma Sandwiches. This is also great as a salad base for things like Crispy Baked Chickpeas.", url)

    # @it = found_sentence("o a large mixing bowl, add pa", url)

  end

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

    site = "#{Nokogiri::HTML(open(url)).inner_text}" # this is the website source code
    esite = Nokogiri::HTML(open(url)) # this is the website source code

    jsite = esite.inner_html # doesn't display article

    # grab the index of the first and last step
    f_index = site.index(first_step)
    l_index = site.index("#{last_step}")#(last_step)

    return site #l_index

    #the last step should have a higher index
    if l_index and l_index > f_index
      # Great, continue
      pry_instructions = site[f_index...l_index] + "#{f_index}" + "--"+ "#{l_index}"
      return first_step + "||" + last_step + "||" + pry_instructions
    else
      # there is a big problem here
      return "big problem"
    end

  end

  def count_ap(string, substring)
  string.scan(/(?=#{substring})/).count
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
