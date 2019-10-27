class Api::V1::BuildingsController < ApplicationController
  before_action :set_building, only: [:show, :update, :destroy]

  # GET /buildings
  def index

    buildings = Building.all

    render json: buildings
  end

  # GET /buildings/{id}
  def show

    render json: @building.as_json
  end

  # POST /buildings
  def create
    @building = Building.new(building_params)

    if @building.save
      Building::VERSIONING_ATTRIBUTES.each do |attribute|
        @building.versionings.create(type_attribute: attribute, value: building_params[attribute])
      end
      render json: @building.as_json, status: 201
    else
      render json: @building.errors, status: :unprocessable_entity
    end
  end

  # PUT /buildings/{id}
  def update
    if @building.update(building_params)
      Building::VERSIONING_ATTRIBUTES.each do |attribute|
        @building.versionings.create(type_attribute: attribute, value: building_params[attribute])
      end

      render json: @building, status: :ok
    else
      render json: @building.errors, status: :unprocessable_entity
    end
  end

  # DELETE /buildings/{id}
  def destroy
    @building.destroy

    head :no_content
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_building
      @building = Building.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def building_params
      permitted_parameters = %i[reference address zip_code city country manager_name]
      params.require(:building).permit(permitted_parameters)
    end
end
