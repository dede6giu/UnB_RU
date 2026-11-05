class RechargesController < ApplicationController
  include StudentAuthentication

  def new
    @recharge = Recharge.new(package: 5, payment_method: "pix")
  end

  def create
    @recharge = Recharge.new(recharge_params.merge(student: @student))

    if @recharge.save
      redirect_to statement_path, notice: "Recarga realizada com sucesso."
    else
      flash.now[:alert] = @recharge.errors.first.message
      render :new, status: :unprocessable_content
    end
  end

  private

  def recharge_params
    params.require(:recharge).permit(:package, :quantity, :payment_method,
                                     :card_number, :card_expiry_month, :card_expiry_year, :card_cvv)
  end
end
