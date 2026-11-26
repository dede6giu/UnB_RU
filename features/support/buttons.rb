module ButtonPaths
  def button_path(button_alias)
    case button_alias
    when "criar restaurante", "salvar restaurante",
      "criar catraca", "salvar catraca", "registrar"
      "commit"
    when "remover restaurante", "remover catraca"
      "btn_destroy"
    when "login"
      "Entrar"
    when "disconnect from turnstile"
      "Desconectar do Ponto de Acesso"
    when "confirmar transação"
      "Confirmar"
    when "exportar PDF", "export PDF", "export extract"
      "Exportar PDF"
    when "cardápio completo"
      "Ver cardápio completo"
    when "save configuration"
      "Salvar configuração"
    when "login do estudante"
      "Entrar como estudante"
    when "cadastro do estudante"
      "Cadastre-se"
    when "login do operador"
      "Entrar como operador"
    when "login do admin"
      "Entrar como administrador"
    else
      pending "Can't find mapping from \"#{button_alias}\" to a path.\n" +
            "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(ButtonPaths)
