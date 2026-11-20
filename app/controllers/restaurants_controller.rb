class RestaurantsController < ApplicationController
  layout "admin"
  before_action :set_restaurant, only: %i[ show edit update destroy ]

  ##
  # GET /admin/restaurants
  #
  # Carrega todas os restaurants como variável de instância (para uso em views).
  def index
    @restaurants = Restaurant.all
  end

  ##
  # GET /admin/restaurants/1 or /restaurants/1.json
  #
  # Redireciona a chamada para RestaurantsController#index
  def show
    redirect_to restaurants_path
  end

  ##
  # GET /admin/restaurants/new
  #
  # Cria um restaurant vazio na variável de instância para uso
  # durante a tela de criação de restaurant.
  def new
    @restaurant = Restaurant.new
  end

  ##
  # GET /admin/restaurants/:id/edit
  #
  # Chamado durante o processo, mas não realiza nada.
  def edit
  end

  ##
  # POST /admin/restaurants ou /admin/restaurants.json
  #
  # Chamado com POST, na página de new do restaurant.
  # Salva um novo restaurant na database se nenhum erro for encontrado nas verificações.
  #
  # No caso de sucesso, redireciona para RestaurantsController#index.
  #
  # No caso de falha, retorna os parâmetros necessários para exibir a falha em RestaurantsController#new, e
  # nada é alterado na database.
  def create
    @restaurant = Restaurant.new(restaurant_params)

    respond_to do |format|
      if @restaurant.save
        format.html { redirect_to restaurants_path, notice: "Restaurante criado com sucesso." }
        format.json { render :show, status: :created, location: @restaurant }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @restaurant.errors, status: :unprocessable_content }
      end
    end
  end

  ##
  # PATCH/PUT /admin/restaurants/1 or /admin/restaurants/1.json
  #
  # Chamado com PATCH/PUT, na página de edit do restaurant.
  # Atualiza o restaurant `:id` na database se nenhum erro for encontrado nas verificações.
  #
  # No caso de sucesso, redireciona para RestaurantsController#index.
  #
  # No caso de falha, retorna os parâmetros necessários para exibir a falha em RestaurantsController#edit, e
  # nada é alterado na database.
  def update
    respond_to do |format|
      if @restaurant.update(restaurant_params)
        format.html { redirect_to restaurants_path, notice: "Restaurante atualizado com sucesso.", status: :see_other }
        format.json { render :show, status: :ok, location: @restaurant }
      else
        @restaurant.reload
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @restaurant.errors, status: :unprocessable_content }
      end
    end
  end

  ##
  # DELETE /admin/restaurants/1 or /admin/restaurants/1.json
  #
  # Chamado após confirmar deleção na página de edição.
  # Apaga o restaurant na database se nenhum erro for encontrado nas verificações.
  #
  # No caso de sucesso, redireciona para RestaurantsController#index. O restaurant não existe mais no registro.
  #
  # No caso de falha, retorna os parâmetros necessários para exibir a falha em RestaurantsController#edit, e
  # nada é alterado na database.
  def destroy
    @restaurant.destroy!

    respond_to do |format|
      format.html { redirect_to restaurants_path, notice: "Restaurante destruído com sucesso.", status: :see_other }
      format.json { head :no_content }
    end
  rescue ActiveRecord::RecordNotDestroyed
    respond_to do |format|
      format.html { render :edit, status: :unprocessable_content }
      format.json { render json: @restaurant.errors, status: :unprocessable_content }
    end
  end

  private

  before_action :exigir_admin
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
