class AdminSessionsController < ApplicationController
  def new
  end

  def create
    admin_params = params.require(:admin).permit(:user, :password)
    if admin_params[:user] !~ Account.user_format_for("admin")
      flash.now[:alert] = "Matrícula inválida."
      render :new, status: :unprocessable_entity
      return
    end
    admin = Account.find_by(user: admin_params[:user], role: "admin")
    if admin && admin.authenticate(admin_params[:password])
      session[:admin_id] = admin.id
      redirect_to restaurants_path, notice: "Sucesso na autenticação."
    else
      flash.now[:alert] = "Matrícula ou senha incorretas."
      render :new, status: :unprocessable_entity
    end
  end

  # Sai da conta do admin e volta para o login
  def destroy
    session.delete(:admin_id)
    redirect_to new_admin_session_path, notice: "Você saiu da conta."
  end
end
