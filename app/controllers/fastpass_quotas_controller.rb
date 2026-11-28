# Tela "Vagas e Cotas FastPass" do admin.
class FastpassQuotasController < ApplicationController
  include AdminAuthentication
  layout "admin"

  ##
  # Mostra cada janela de horário com a cota dela, a cota padrão e a capacidade das catracas FastPass.
  #
  # Não recebe argumentos. Renderiza a tela; não altera o banco.
  def edit
    load_page
  end

  ##
  # Aplica as cotas digitadas (`params[:quotas]`, por id da janela). Se alguma for inválida, não salva
  # nenhuma.
  #
  # Não retorna valor útil. Com todas válidas, grava as cotas e redireciona para a tela com aviso de
  # sucesso; senão, mostra a tela de novo com "Cota inválida." e status 422.
  def update
    load_page
    if apply_quotas
      redirect_to fastpass_quotas_path, notice: "Cotas aplicadas ao próximo sorteio."
    else
      flash.now[:alert] = "Cota inválida."
      render :edit, status: :unprocessable_entity
    end
  end

  ##
  # Volta todas as janelas para a cota padrão.
  #
  # Não recebe argumentos nem retorna valor útil. Apaga a cota de todas as janelas no banco e
  # redireciona para a tela com aviso.
  def restore
    Timeframe.update_all(quota: nil)
    redirect_to fastpass_quotas_path, notice: "Cotas padrão restauradas."
  end

  private

  ##
  # Carrega o que a tela mostra.
  #
  # Não recebe argumentos. Define `@timeframes`, `@capacity` (soma das catracas FastPass) e
  # `@default_quota`; só lê o banco.
  def load_page
    @timeframes = Timeframe.order(:starts_at).to_a
    @capacity = Turnstile.where(fastpass_corridor: true).sum(:capacity)
    @default_quota = FastPassSetting.global.default_quota
  end

  ##
  # Coloca nas janelas as cotas digitadas (vazio volta para o padrão) e salva se todas forem válidas.
  #
  # Não recebe argumentos. Retorna `true` quando salvou e `false` quando alguma cota é inválida (aí nada
  # é gravado no banco).
  def apply_quotas
    @timeframes.each { |timeframe| timeframe.quota = params.dig(:quotas, timeframe.id.to_s).presence }
    return false unless @timeframes.all? { |timeframe| timeframe.valid? }

    @timeframes.each { |timeframe| timeframe.save! }
    true
  end
end
