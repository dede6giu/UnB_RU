# Tela "Sorteio e Gestão do FastPass" do estudante.
class FastpassController < ApplicationController
  include StudentAuthentication

  ##
  # Mostra em que fase está o FastPass de cada refeição agora.
  #
  # Não recebe argumentos. Define `@shifts` (turnos com as janelas) e `@cycle` (FastPassCycle do
  # momento atual) e renderiza a tela; não altera o banco.
  def show
    @shifts = Shift.includes(:timeframes).order(:starts_at)
    @cycle = FastPassCycle.new(@shifts, Time.current)
  end
end
