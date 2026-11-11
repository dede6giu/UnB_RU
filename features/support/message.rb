module MessageTexts
  def message_kind(message_alias)
    case message_alias

    # Restaurant
    when /restaurant name is empty/
      'Nome não pode ser vazio'
    when /restaurant campus is empty/
      'Campus não pode ser vazio'
    when /existing restaurant/
      'Restaurante já existente'

    # Turnstile
    when /turnstiles in operation/
      'Há catracas em operação'
    when /turnstile in operation/
      'A catraca está em operação'
    when /turnstile name is empty/
      'Nome não pode ser vazio'
    when /existing turnstile/
      'Catraca já existente'

    else
      raise "Can't find mapping from \"#{message_alias}\" to a message.\n" +
            "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(MessageTexts)
