class GlobalHistoriesController < ApplicationController
  layout "admin"
  before_action :exigir_admin

  ##
  # Lista os acessos de todos os restaurantes, do mais novo para o mais antigo.
  #
  # Recebe os filtros opcionais `restaurant_id` e `turnstile_id` pela requisição.
  # Retorna a coleção de `Access` já filtrada e ordenada.
  # Não altera o banco de dados.
  def index
    @accesses = filtered_accesses
    @restaurants = Restaurant.order(:campus, :name)
    @turnstiles = Turnstile.for_restaurant(params[:restaurant_id]).includes(:restaurant).order(:name)
  end

  private

  ##
  # Monta a consulta do histórico com filtros e ordenação.
  #
  # Não recebe argumentos (lê `params`). Retorna uma `ActiveRecord::Relation` de `Access`.
  # Não altera o banco de dados.
  def filtered_accesses
    Access.includes(:restaurant, :turnstile, student: :account)
          .for_restaurant(params[:restaurant_id])
          .for_turnstile(params[:turnstile_id])
          .newest_first
  end

  ##
  # Garante que só um admin autenticado acesse o histórico global.
  #
  # Não recebe argumentos (lê `session[:admin_id]`). Não retorna valor útil.
  # Efeito colateral: redireciona para o login de admin com alerta quando não há sessão.
  def exigir_admin
    return if session[:admin_id].present?

    redirect_to new_admin_session_path, alert: "Faça login para continuar."
  end
end
