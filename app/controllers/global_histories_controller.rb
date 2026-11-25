class GlobalHistoriesController < ApplicationController
  layout "admin"
  before_action :exigir_admin

  ##
  # Lista os acessos de todos os restaurantes, do mais novo para o mais antigo.
  #
  # Recebe os filtros opcionais `restaurant_id`, `turnstile_id` e `date` pela requisição.
  # Responde em HTML ou PDF (`format.pdf`).
  # Não altera o banco de dados.
  def index
    @accesses = filtered_accesses
    @restaurants = Restaurant.order(:campus, :name)
    @turnstiles = Turnstile.for_restaurant(params[:restaurant_id]).includes(:restaurant).order(:name)

    respond_to do |format|
      format.html
      format.pdf { export_pdf }
    end
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
          .for_date(params[:date])
          .newest_first
  end

  ##
  # Envia o PDF do filtro atual ou volta para a página com aviso quando não há acessos.
  #
  # Não recebe argumentos (lê `params` e `@accesses`). Não retorna valor útil.
  # Efeito colateral: envia dados (`send_data`) ou redireciona com `flash[:alert]`.
  def export_pdf
    if @accesses.empty?
      redirect_to global_history_path(filter_params), alert: "Ainda não há histórico de acessos."
    else
      send_data global_history_pdf.render,
                filename: "historico-global-#{Date.current.iso8601}.pdf",
                type: "application/pdf"
    end
  end

  ##
  # Monta o PDF com os acessos e os rótulos dos filtros.
  #
  # Não recebe argumentos. Retorna um `GlobalHistoryPdf` pronto para `render`; não altera o banco.
  def global_history_pdf
    GlobalHistoryPdf.new(@accesses, **filter_labels)
  end

  ##
  # Traduz os IDs dos filtros para os nomes exibidos no PDF.
  #
  # Não recebe argumentos (lê `params`). Retorna um hash com `:restaurant`, `:turnstile` e `:date`.
  # Não altera o banco de dados.
  def filter_labels
    {
      restaurant: Restaurant.find_by(id: params[:restaurant_id])&.name || "Todos",
      turnstile: Turnstile.find_by(id: params[:turnstile_id])&.name || "Todas",
      date: date_label
    }
  end

  ##
  # Formata a data do filtro para `dd/mm/aaaa`.
  #
  # Não recebe argumentos (lê `params[:date]`). Retorna a data formatada ou `"Todas"`.
  # Não altera o banco de dados.
  def date_label
    Date.iso8601(params[:date].to_s).strftime("%d/%m/%Y")
  rescue Date::Error
    "Todas"
  end

  ##
  # Mantém apenas os filtros preenchidos ao redirecionar.
  #
  # Não recebe argumentos (lê `params`). Retorna um hash sem valores em branco.
  # Não altera o banco de dados.
  def filter_params
    {
      restaurant_id: params[:restaurant_id],
      turnstile_id: params[:turnstile_id],
      date: params[:date]
    }.compact_blank
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
