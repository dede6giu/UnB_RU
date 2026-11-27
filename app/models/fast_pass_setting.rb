# Configuração única do FastPass: tolerância de atraso, liberação antecipada e cota padrão das janelas.
class FastPassSetting < ApplicationRecord
  validates :delay_tolerance_minutes,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :early_release_minutes,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  ##
  # A configuração do FastPass (só existe uma).
  #
  # Não recebe argumentos. Retorna o FastPassSetting; na primeira vez, cria o registro com os valores
  # padrão no banco.
  def self.global
    find_or_create_by!(singleton: true)
  end
end
