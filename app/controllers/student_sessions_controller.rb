class StudentSessionsController < ApplicationController
  def new
  end
  def create
    student_params = params.require(:student).permit(:user, :password)
    if student_params[:user] !~ Account.user_format_for("student")
      flash.now[:alert] = "Matrícula inválida."
      render :new, status: :unprocessable_entity
      return
    end
    student = Account.find_by(user: student_params[:user], role: "student")
    if student && student.authenticate(student_params[:password])
      session[:student_id] = student.id

      redirect_to student_portal_path, notice: "Sucesso na autenticação."
    else
      flash.now[:alert] = "Matrícula ou senha incorretas."
      render :new, status: :unprocessable_entity
    end
  end
end
