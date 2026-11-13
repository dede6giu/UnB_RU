class StatementsController < ApplicationController
  include StudentAuthentication

  def show
    @transactions = @student.transactions.in_period(params[:period]).of_type(params[:type])
                            .order(created_at: :desc, id: :desc)

    respond_to do |format|
      format.html { prepare_page }
      format.pdf { export_pdf }
    end
  end

  private

  def prepare_page
    @spent_cents = @transactions.spent_cents
    @meals_count = @transactions.meals_count
    @recharged_cents = @transactions.recharged_cents

    @total_pages = @transactions.total_pages
    @page = params[:page].to_s.to_i.clamp(1, @total_pages)
    @page_transactions = @transactions.page(@page)
  end

  # o PDF leva todos os lançamentos do filtro, não só os da página
  def export_pdf
    if @transactions.empty?
      redirect_to statement_path(period: params[:period], type: params[:type]), alert: "Não há lançamentos para exportar."
    else
      pdf = StatementPdf.new(@student, @transactions, period: params[:period], type: params[:type])
      send_data pdf.render, filename: "extrato-#{Date.current}.pdf", type: "application/pdf"
    end
  end
end
