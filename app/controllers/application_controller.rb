class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_admin, :current_operator, :current_student

  private

  ##
  # Admin logado na sessão atual.
  #
  # Não recebe argumentos. Retorna a Account do admin cuja matrícula está em
  # <tt>session[:admin_id]</tt>, ou +nil+ se ninguém estiver logado como admin.
  # Não tem efeitos colaterais além de guardar o resultado em <tt>@current_admin</tt>.
  def current_admin
    @current_admin ||= Account.find_by(user: session[:admin_id], role: "admin")
  end

  ##
  # Operador logado na sessão atual.
  #
  # Não recebe argumentos. Retorna a Account do operador cuja matrícula está em
  # <tt>session[:operator_id]</tt>, ou +nil+ se ninguém estiver logado como operador.
  # Não tem efeitos colaterais além de guardar o resultado em <tt>@current_operator</tt>.
  def current_operator
    @current_operator ||= Account.find_by(user: session[:operator_id], role: "operator")
  end

  ##
  # Estudante logado na sessão atual.
  #
  # Não recebe argumentos. Busca a Account de estudante cuja matrícula está em
  # <tt>session[:student_id]</tt> e retorna o Student dela (é ele que tem saldo e
  # lançamentos), ou +nil+ se ninguém estiver logado como estudante.
  # Não tem efeitos colaterais além de guardar o resultado em <tt>@current_student</tt>.
  def current_student
    @current_student ||= Account.find_by(user: session[:student_id], role: "student")&.student
  end
end
