# Fase do FastPass de cada refeição num momento do dia: inscrição aberta, sorteio realizado, em
# andamento, inativo ou sem FastPass. Não é gravado no banco; é calculado a partir dos turnos.
class FastPassCycle
  # O resultado do sorteio sai uma hora antes de o turno abrir (Figma).
  RAFFLE_ADVANCE = 1.hour

  ##
  # Recebe os turnos (Shift) e o momento a considerar (um Time). Guarda os turnos em ordem de início e
  # o momento em segundos desde a meia-noite. Não altera o banco.
  def initialize(shifts, now)
    @shifts = shifts.sort_by { |shift| shift.starts_at.seconds_since_midnight }
    @seconds = now.seconds_since_midnight
  end

  ##
  # Turno com a inscrição aberta: o primeiro cujo sorteio ainda vai acontecer. Depois do último sorteio
  # do dia, volta para o primeiro turno (o de amanhã).
  #
  # Não recebe argumentos. Retorna um Shift, ou `nil` se não houver turnos. Sem efeitos colaterais.
  def open_shift
    @shifts.find { |shift| raffle_seconds(shift) > @seconds } || @shifts.first
  end

  ##
  # Fase do FastPass do turno no momento guardado.
  #
  # Recebe o Shift. Retorna "unavailable" (sem janelas), "active" (durante o turno), "pending" (entre o
  # sorteio e o início), "open" (inscrição aberta) ou "inactive". Só lê as janelas do turno.
  def status_of(shift)
    return "unavailable" if shift.timeframes.empty?
    return "active" if during_shift?(shift)
    return "pending" if between_raffle_and_start?(shift)

    shift == open_shift ? "open" : "inactive"
  end

  ##
  # Hora em que sai o resultado do sorteio do turno.
  #
  # Recebe o Shift. Retorna o horário (uma hora antes do início do turno). Sem efeitos colaterais.
  def raffle_time(shift)
    shift.starts_at - RAFFLE_ADVANCE
  end

  private

  ##
  # Diz se o momento guardado está dentro do turno.
  #
  # Recebe o Shift. Retorna `true` ou `false`; sem efeitos colaterais.
  def during_shift?(shift)
    @seconds >= shift.starts_at.seconds_since_midnight && @seconds < shift.ends_at.seconds_since_midnight
  end

  ##
  # Diz se o momento guardado fica entre o resultado do sorteio e o início do turno.
  #
  # Recebe o Shift. Retorna `true` ou `false`; sem efeitos colaterais.
  def between_raffle_and_start?(shift)
    @seconds >= raffle_seconds(shift) && @seconds < shift.starts_at.seconds_since_midnight
  end

  ##
  # Hora do resultado do sorteio do turno, em segundos desde a meia-noite.
  #
  # Recebe o Shift. Retorna um número; sem efeitos colaterais.
  def raffle_seconds(shift)
    raffle_time(shift).seconds_since_midnight
  end
end
