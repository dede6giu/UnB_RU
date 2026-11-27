# Sorteio do FastPass de uma janela de horário.
class FastPassRaffle
  ##
  # Recebe a janela (Timeframe) a sortear. Não altera o banco.
  def initialize(timeframe)
    @timeframe = timeframe
  end

  ##
  # Sorteia entre os inscritos da janela no máximo a cota dela.
  #
  # Não recebe argumentos nem retorna valor útil. Escreve no banco: quem foi sorteado fica com status
  # "won" e os outros inscritos com "lost".
  def draw
    inscritos = @timeframe.fast_pass_enrollments.where(status: "enrolled").to_a.shuffle
    ganhadores = inscritos.first(@timeframe.effective_quota)

    inscritos.each do |inscricao|
      inscricao.update!(status: ganhadores.include?(inscricao) ? "won" : "lost")
    end
  end
end
