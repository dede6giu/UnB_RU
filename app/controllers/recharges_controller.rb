# Controller da Recarga de Saldo do estudante. Só funciona com o estudante logado
# (StudentAuthentication); quem não entrou vai para o login.
class RechargesController < ApplicationController
  include StudentAuthentication

  ##
  # GET /student/recharge
  #
  # Mostra a tela de recarga com o pacote de 5 refeições e o PIX já escolhidos.
  #
  # Não recebe argumentos e não altera o banco.
  def new
    @recharge = Recharge.new(package: 5, payment_method: "pix")
  end

  ##
  # POST /student/recharge
  #
  # Faz a recarga com o que veio do formulário (pacote ou outra quantidade, meio de pagamento e, no
  # cartão, os dados dele).
  #
  # No caso de sucesso, soma o valor ao saldo, registra um crédito no extrato e volta para a tela de
  # recarga com a mensagem de sucesso. No caso de falha, mostra a tela de novo com o primeiro erro
  # (status 422) e nada é alterado no banco.
  def create
    @recharge = Recharge.new(recharge_params.merge(student: @student))

    if @recharge.save
      redirect_to new_recharge_path, notice: "Recarga realizada com sucesso."
    else
      flash.now[:alert] = @recharge.errors.first.message
      render :new, status: :unprocessable_content
    end
  end

  private

  ##
  # Campos do formulário de recarga que o controller aceita.
  #
  # Não recebe argumentos. Retorna os parâmetros permitidos de `params[:recharge]`; sem efeitos colaterais.
  def recharge_params
    params.require(:recharge).permit(:package, :quantity, :payment_method,
                                     :card_number, :card_expiry_month, :card_expiry_year, :card_cvv)
  end
end
