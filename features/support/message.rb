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

    else
      raise "Can't find mapping from \"#{message_alias}\" to a message.\n" +
            "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(MessageTexts)