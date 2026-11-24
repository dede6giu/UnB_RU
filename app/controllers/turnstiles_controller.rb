# Controller para o model Turnstile. Ações CRUD são disponíveis para apenas usuários
# atualmente autenticados como admins, enquanto Read é permitido para qualquer usuário.
class TurnstilesController < ApplicationController
  layout "admin"
  before_action :exigir_admin
  before_action :set_turnstile, only: %i[ show edit update destroy ]

  ##
  # GET /admin/turnstiles
  #
  # Retorna a chamada para RestaurantsController#index.
  # Também carrega todas as turnstiles como variável de instância (para uso em views).
  def index
    @turnstiles = Turnstile.all
    redirect_to restaurants_path
  end

  ##
  # GET /admin/turnstiles/:id
  #
  # Retorna a chamada para RestaurantsController#index.
  # Também carrega o restaurante específico da turnstile `:id` como variável de instância.
  def show
    @restaurant = Restaurant.find(@turnstile.restaurant_id)
    redirect_to restaurants_path
  end

  ##
  # GET /admin/turnstiles/new
  #
  # Cria uma nova turnstile vazia na variável de instância para uso
  # durante a tela de criação de turnstile.
  def new
    @turnstile = Turnstile.new
  end

  ##
  # GET /admin/turnstiles/:id/edit
  #
  # Salva o valor do restaurant atribuído à turnstile para uso durante a tela de edição de turnstile.
  def edit
    @restaurant = Restaurant.find(@turnstile.restaurant_id)
  end

  ##
  # POST /admin/turnstiles ou /admin/turnstiles.json
  #
  # Chamado com POST, na página de new da turnstile.
  # Salva uma nova turnstile na database se nenhum erro for encontrado nas verificações.
  #
  # No caso de sucesso, redireciona para RestaurantsController#index.
  #
  # No caso de falha, retorna os parâmetros necessários para exibir a falha em TurnstilesController#new, e
  # nada é alterado na database.
  def create
    @turnstile = Turnstile.new(turnstile_params)

    if @turnstile.save
      redirect_to restaurants_path, notice: "Catraca criada com sucesso."
    else
      render :new, status: :unprocessable_content
    end
  end

  ##
  # PATCH/PUT /admin/turnstiles/1 or /admin/turnstiles/1.json
  #
  # Chamado após confirmar na página de edição.
  # Atualiza a turnstile `:id` na database se nenhum erro for encontrado nas verificações.
  #
  # No caso de sucesso, redireciona para RestaurantsController#index.
  #
  # No caso de falha, retorna os parâmetros necessários para exibir a falha em TurnstilesController#edit, e
  # nada é alterado na database.
  def update
    if @turnstile.update(turnstile_params)
      redirect_to restaurants_path, notice: "Catraca atualizada com sucesso.", status: :see_other
    else
      @turnstile.reload
      render :edit, status: :unprocessable_content
    end
  end

  ##
  # DELETE /admin/turnstiles/1 or /admin/turnstiles/1.json
  #
  # Chamado após confirmar deleção na página de edição. Tenta realizar `destroy!`.
  # Apaga a turnstile na database se nenhum erro for encontrado nas verificações.
  #
  # No caso de sucesso, redireciona para RestaurantsController#index. A turnstile não existe mais no registro.
  #
  # No caso de falha, retorna os parâmetros necessários para exibir a falha em TurnstileController#edit, e
  # nada é alterado na database.
  def destroy
    @turnstile.destroy!
    redirect_to restaurants_path, notice: "Catraca destruída com sucesso.", status: :see_other
  rescue ActiveRecord::RecordNotDestroyed
    render :edit, status: :unprocessable_content
  end

  private

  def exigir_admin
    return if session[:admin_id].present?

    redirect_to new_admin_session_path, alert: "Faça login para continuar."
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_turnstile
    @turnstile = Turnstile.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def turnstile_params
    params.expect(turnstile: [ :name, :operation, :restaurant_id ])
  end
end
