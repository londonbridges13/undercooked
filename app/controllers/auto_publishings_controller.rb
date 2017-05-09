class AutoPublishingsController < ApplicationController
  before_action :set_auto_publishing, only: [:show, :edit, :update, :destroy]

  # GET /auto_publishings
  # GET /auto_publishings.json
  def index
    @auto_publishings = AutoPublishing.all
  end

  # GET /auto_publishings/1
  # GET /auto_publishings/1.json
  def show
  end

  # GET /auto_publishings/new
  def new
    @auto_publishing = AutoPublishing.new
  end

  # GET /auto_publishings/1/edit
  def edit
  end

  # POST /auto_publishings
  # POST /auto_publishings.json
  def create
    @auto_publishing = AutoPublishing.new(auto_publishing_params)

    respond_to do |format|
      if @auto_publishing.save
        format.html { redirect_to @auto_publishing, notice: 'Auto publishing was successfully created.' }
        format.json { render :show, status: :created, location: @auto_publishing }
      else
        format.html { render :new }
        format.json { render json: @auto_publishing.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /auto_publishings/1
  # PATCH/PUT /auto_publishings/1.json
  def update
    respond_to do |format|
      if @auto_publishing.update(auto_publishing_params)
        format.html { redirect_to @auto_publishing, notice: 'Auto publishing was successfully updated.' }
        format.json { render :show, status: :ok, location: @auto_publishing }
      else
        format.html { render :edit }
        format.json { render json: @auto_publishing.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /auto_publishings/1
  # DELETE /auto_publishings/1.json
  def destroy
    @auto_publishing.destroy
    respond_to do |format|
      format.html { redirect_to auto_publishings_url, notice: 'Auto publishing was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_auto_publishing
      @auto_publishing = AutoPublishing.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def auto_publishing_params
      params.require(:auto_publishing).permit(:reasons)
    end
end
