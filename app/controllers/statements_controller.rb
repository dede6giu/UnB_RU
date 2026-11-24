class StatementsController < ApplicationController
  include StudentAuthentication
  helper_method :filters

  def show
    @transactions = filtered_transactions

    respond_to do |format|
      format.html { prepare_page }
      format.pdf { export_pdf }
    end
  end

  private

  ##
  # Filtros escolhidos na tela do extrato: `params[:period]`, `params[:type]` e `params[:restaurant]`.
  # A view usa para montar os links das páginas e do PDF.
  #
  # Retorna um hash com as chaves `:period`, `:type` e `:restaurant` (cada uma pode ser `nil`). Sem efeitos
  # colaterais.
  def filters
    { period: params[:period], type: params[:type], restaurant: params[:restaurant] }
  end

  ##
  # Lançamentos do estudante que entrou, filtrados por período, tipo e restaurante, do mais novo para o
  # mais antigo.
  #
  # Não recebe argumentos (usa os filtros). Retorna uma consulta de Transaction; não altera o banco.
  def filtered_transactions
    @student.transactions.in_period(filters[:period]).of_type(filters[:type])
            .for_restaurant(filters[:restaurant]).order(created_at: :desc, id: :desc)
  end

  def prepare_page
    @spent_cents = @transactions.spent_cents
    @meals_count = @transactions.meals_count
    @recharged_cents = @transactions.recharged_cents

    @total_pages = @transactions.total_pages
    @page = params[:page].to_s.to_i.clamp(1, @total_pages)
    @page_transactions = @transactions.page(@page).includes(access: [ :shift, :restaurant, :turnstile ])
    @restaurants = Restaurant.order(:name)
  end

  # o PDF leva todos os lançamentos do filtro, não só os da página
  def export_pdf
    if @transactions.empty?
      redirect_to statement_path(filters), alert: "Não há lançamentos para exportar."
    else
      send_data statement_pdf.render, filename: "extrato-#{Date.current}.pdf", type: "application/pdf"
    end
  end

  ##
  # Monta o PDF do extrato com os lançamentos do filtro (todos, não só os da página).
  #
  # Não recebe argumentos. Retorna um StatementPdf pronto para `render`; não altera o banco.
  def statement_pdf
    StatementPdf.new(@student, @transactions, period: filters[:period], type: filters[:type],
                                              restaurant: filters[:restaurant])
  end
end
