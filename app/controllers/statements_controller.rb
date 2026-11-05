class StatementsController < ApplicationController
  include StudentAuthentication

  def show
    @transactions = @student.transactions.order(created_at: :desc, id: :desc)
  end
end
