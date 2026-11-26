# Controla as rotas relacionadas ao registro, atuação e desconexão de ponto
# para operadores.
class AccessPointsController < ApplicationController
  layout "operator"
  before_action :load_restaurants, only: %i[new create]
  before_action :set_operator_turnstile, only: %i[show validate]


  ##
  # GET /operator/access/new
  #
  # Chamado durante o processo, mas não realiza nada.
  def new
  end

  ##
  # GET /operator/access
  #
  # Prepara variáveis relacionadas ao controle de catraca, para serem
  # usadas na view.
  #
  # Notavelmente, se o operador não tiver uma catraca associada ainda,
  # este é redirecionado para AccessPointsController#new.
  def show
    redirect_to new_access_point_path if @turnstile.nil?
    @entry = flash[:entry]
    @student = Student.find_by(user: flash[:registration])
  end

  ##
  # POST /operator/access/validate
  #
  # Valida a matrícula digitada no Terminal de Validação (`params[:registration]`). Com saldo, libera e
  # cobra a refeição; sem saldo ou com matrícula não cadastrada, bloqueia.
  #
  # Não retorna valor: redireciona para o Terminal de Validação com o resultado e a matrícula no flash,
  # assim atualizar a página não cobra de novo. Quando libera, cria um débito e diminui o saldo do estudante.
  def validate
    student = Student.find_by(user: params[:registration])
    result = entry_result(student)
    register_access(student, result)

    redirect_to access_point_path, flash: { entry: result, registration: params[:registration] }
  end

  ##
  # POST /operator/access
  #
  # Associa um operador (atualmente autenticado) com uma turnstile.
  #
  # Se a turnstile não existe, ou está Inativa, ou está em operação por outro operador,
  # então a associação falha. O operador recebe a mensagem explicando qual falha ocorreu.
  #
  # Se há sucesso, o operador é associado à catraca, e este é redirecionado
  # para AccessPointsController#show.
  def create
    operator = Account.find_by(user: session[:operator_id], role: "operator")
    turnstile = Turnstile.find_by(id: params.dig(:access_point, :turnstile_id))
    erro = erro_da_catraca(turnstile)
    return render_error(erro) if erro

    assumir_catraca(turnstile, operator)

    redirect_to access_point_path, notice: "Operação iniciada com sucesso."
  end

  ##
  # DELETE /operator/access
  #
  # Desvincula um operador de sua catraca associada, e avisa se houve sucesso ou
  # se não havia catraca para desvincular.
  #
  # Independente do resultado, o operador é redirecionado para AccessPointsController#new.
  def destroy
    turnstile = Turnstile.find_by(operator_id: session[:operator_id])
    if turnstile.nil?
      redirect_to new_access_point_path, alert: "Nenhum ponto de acesso em operação."
    else
      turnstile.update!(operator_id: nil, operation: "Ativa")
      redirect_to new_access_point_path, notice: "Operação encerrada com sucesso."
    end
  end

  ##
  # GET /operator/access/confirm_disconnect
  #
  # O método não realiza nada, mas é usado para chamar a confirmação de DELETE /operator/access
  def confirm_disconnect
  end

  private

  before_action :exigir_operador

  def load_restaurants
    @restaurants = Restaurant.includes(:turnstiles).order(:campus, :name)
  end

  ##
  # Carrega a catraca em operação do operador logado.
  #
  # Não recebe argumentos. Define `@turnstile` (ou `nil` quando não há catraca em operação).
  # Não altera o banco de dados.
  def set_operator_turnstile
    @turnstile = Turnstile.find_by(operator_id: session[:operator_id])
  end

  ##
  # Decide o resultado da validação para o estudante encontrado pela matrícula (`nil` se não existe).
  #
  # Retorna `"not_found"`, `"allowed"` ou `"no_balance"`. Quando retorna `"allowed"`, já cobrou a
  # refeição (ver Student#pay_meal).
  def entry_result(student)
    if student.nil?
      "not_found"
    elsif student.pay_meal
      "allowed"
    else
      "no_balance"
    end
  end

  ##
  # Registra o acesso do terminal de validação no histórico global.
  #
  # Recebe o estudante encontrado (ou `nil`) e o resultado de `entry_result`.
  # Retorna o `Access` criado, ou `nil` quando não há catraca em operação.
  # Escreve no banco: cria um `Access` com o turno da hora atual (vazio fora dos turnos); quando liberado,
  # vincula o débito gerado.
  def register_access(student, result)
    return if @turnstile.nil?

    Access.transaction do
      access = Access.create!(
        student: student,
        registration: params[:registration],
        restaurant: @turnstile.restaurant,
        turnstile: @turnstile,
        shift: Shift.at(Time.current),
        status: result == "allowed" ? "allowed" : "blocked",
        reason: access_reason(result)
      )
      link_debit(access) if result == "allowed"
    end
  end

  ##
  # Traduz o resultado de `entry_result` para o motivo gravado no acesso.
  #
  # Retorna `"no_balance"`, `"not_found"` ou `nil` (acesso liberado).
  def access_reason(result)
    return "no_balance" if result == "no_balance"
    return "not_found" if result == "not_found"

    nil
  end

  ##
  # Vincula o débito recém-criado ao acesso liberado.
  #
  # Não retorna valor. Atualiza `transactions.access_id` do último débito do estudante.
  def link_debit(access)
    Transaction.debits.where(student_id: access.student_id).order(:id).last&.update!(access: access)
  end

  ##
  # Mostra mensagem de erro e volta para o formulário de escolha de catraca.
  #
  # Recebe o texto de alerta. Renderiza a view `new` com status 422.
  def render_error(message)
    flash.now[:alert] = message
    render :new, status: :unprocessable_entity
  end

  ##
  # `before_action` que barra quem não está logado como operador.
  #
  # Se existe `session[:operator_id]`, não faz nada e a action continua;
  # se não existe, redireciona para o login do operador com um alerta.
  def exigir_operador
    return if session[:operator_id].present?

    redirect_to new_operator_session_path, alert: "Faça login para continuar."
  end

  ##
  # Verifica se a catraca escolhida pode iniciar uma operação.
  #
  # Recebe a catraca encontrada pelo `turnstile_id` do formulário (ou `nil` se não existe).
  # Retorna a mensagem de erro (catraca não escolhida, Inativa ou já em operação),
  # ou `nil` quando a catraca está livre para operar.
  def erro_da_catraca(turnstile)
    if turnstile.nil?
      "Escolha um ponto de acesso para iniciar a operação."
    elsif turnstile.operation == "Inativa"
      "O ponto de acesso escolhido está inativo."
    elsif %w[ Operando FastPass ].include?(turnstile.operation)
      "O ponto de acesso escolhido já está em operação."
    end
  end

  ##
  # Associa o operador a catraca escolhida, liberando a catraca que ele operava antes.
  #
  # Recebe o operador logado (`Account`) e a catraca escolhida (`Turnstile`), já validada por `erro_da_catraca`.
  #
  # A catraca anterior do operador (se houver) fica "Ativa" e sem operador; a nova fica "Operando" com o operador associado.
  def assumir_catraca(turnstile, operator)
    current_turnstile = Turnstile.find_by(operator_id: operator.id)
    Turnstile.transaction do
      current_turnstile&.update!(operator_id: nil, operation: "Ativa")
      turnstile.update!(operator_id: operator.id, operation: "Operando")
    end
  end
end
