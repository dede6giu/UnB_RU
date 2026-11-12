class OperatorSessionsController < ApplicationController
  def new
  end

    def create
    operator_params = params.require(:operator).permit(:user, :password)
    if operator_params[:user] !~ Account.user_format_for("operator")
      flash.now[:alert] = "Matrícula inválida."
      render :new, status: :unprocessable_entity
      return
    end
    operator = Account.find_by(user: operator_params[:user], role: "operator")
    if operator && operator.authenticate(operator_params[:password])
      session[:operator_id] = operator.id
      redirect_to new_access_point_path, notice: "Sucesso na autenticação."
    else
      flash.now[:alert] = "Matrícula ou senha incorretas."
      render :new, status: :unprocessable_entity
    end
  end
end
