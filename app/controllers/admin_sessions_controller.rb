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
      # TODO: após o merge da branch restaurant-turnstile, trocar por:
      # redirect_to restaurants_path, notice: 'Sucesso na autenticação do administrador.'
      redirect_to admin_sessions_new_path, notice: "Sucesso na autenticação."
    else
      flash.now[:alert] = "Matrícula ou senha incorretas."
      render :new, status: :unprocessable_entity
    end
  end
end
