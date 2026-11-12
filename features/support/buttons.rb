module ButtonPaths
  def button_path(button_alias)
    case button_alias
    when "create restaurant", "save restaurant",
      "create turnstile", "save turnstile"
      "commit"
    when "remove restaurant", "remove turnstile"
      "btn_destroy"
    when "login"
      "Entrar"
    when "disconnect from turnstile"
      "Desconectar do Ponto de Acesso"
    when "confirm transaction"
      "Confirmar"
    when "export PDF"
      "Exportar PDF"
    else
      pending "Can't find mapping from \"#{button_alias}\" to a path.\n" +
            "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(ButtonPaths)
