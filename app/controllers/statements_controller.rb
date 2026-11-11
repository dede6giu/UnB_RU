class StatementsController < ApplicationController
  include StudentAuthentication

  def show
    @transactions = @student.transactions.in_period(params[:period]).order(created_at: :desc, id: :desc)
    @spent_cents = @transactions.debits.sum(:amount_cents)
    @meals_count = @transactions.debits.count
    @recharged_cents = @transactions.credits.sum(:amount_cents)
  end
end
