class RestaurantsController < ApplicationController
  layout "admin"
  before_action :exigir_admin
  before_action :set_restaurant, only: %i[ show edit update destroy ]

  # GET /restaurants or /restaurants.json
  def index
    @restaurants = Restaurant.all
  end

  # GET /restaurants/1 or /restaurants/1.json
  def show
    redirect_to restaurants_path
  end

  # GET /restaurants/new
  def new
    @restaurant = Restaurant.new
  end

  # GET /restaurants/1/edit
  def edit
  end

  # POST /restaurants or /restaurants.json
  def create
    @restaurant = Restaurant.new(restaurant_params)

    if @restaurant.save
      redirect_to restaurants_path, notice: "Restaurante criado com sucesso."
    else
      render :new, status: :unprocessable_content
    end
  end

  # PATCH/PUT /restaurants/1 or /restaurants/1.json
  def update
    if @restaurant.update(restaurant_params)
      redirect_to restaurants_path, notice: "Restaurante atualizado com sucesso.", status: :see_other
    else
      @restaurant.reload
      render :edit, status: :unprocessable_content
    end
  end

  # DELETE /restaurants/1 or /restaurants/1.json
  def destroy
    @restaurant.destroy!
    redirect_to restaurants_path, notice: "Restaurante destruído com sucesso.", status: :see_other
  rescue ActiveRecord::RecordNotDestroyed
    render :edit, status: :unprocessable_content
  end

  private

  def exigir_admin
    return if session[:admin_id].present?

    redirect_to new_admin_session_path, alert: "Faça login para continuar."
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_restaurant
    @restaurant = Restaurant.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def restaurant_params
    params.expect(restaurant: [ :name, :campus ])
  end
end
