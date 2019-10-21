class Api::V1::PersonsController < ApplicationController
  before_action :set_person, only: [:show, :update, :destroy]

  # GET /persons
  def index

    persons = Person.all

    render json: persons
  end

  # GET /persons/{id}
  def show

    render json: @person.as_json
  end

  # POST /persons
  def create
    @person = Person.new(person_params)

    if @person.save
      @person.person_email.create(email: person_params[:email])
      render json: @person.as_json, status: 201
    else
      render json: @person.errors, status: :unprocessable_entity
    end
  end

  # PUT /persons/{id}
  def update
    if @person.update(person_params)

      unless @person.person_email.pluck(:email).include?(person_params[:email])
        @person.person_email.create(email: person_params[:email])
      end
      render json: @person, status: :ok
    else
      render json: @person.errors, status: :unprocessable_entity
    end
  end

  # DELETE /persons/{id}
  def destroy
    @person.destroy

    head :no_content
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_person
      @person = Person.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def person_params
      permitted_parameters = %i[reference email home_phone_number mobile_phone_number firstname lastname address]
      params.require(:person).permit(permitted_parameters)
    end
end
