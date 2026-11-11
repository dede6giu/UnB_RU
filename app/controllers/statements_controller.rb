class StatementsController < ApplicationController
  include StudentAuthentication

  def show
    @transactions = @student.transactions.in_period(params[:period]).order(created_at: :desc, id: :desc)
    @spent_cents = @transactions.debits.sum(:amount_cents)
    @meals_count = @transactions.debits.count
    @recharged_cents = @transactions.credits.sum(:amount_cents)

    @total_pages = @transactions.total_pages
    @page = params[:page].to_i.clamp(1, @total_pages)
    @page_transactions = @transactions.page(@page)
  end
end
