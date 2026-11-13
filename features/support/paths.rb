# Traduz nomes de páginas usados nos cenários para as rotas reais da aplicação.
module NavigationHelpers
  def path_to(page_alias)
    restaurant_base = '/admin/restaurants'
    turnstile_base = '/admin/turnstiles'

    case page_alias
    when /Index/
      '/'

    # Restaurant paths
    when /Gestão de Restaurantes? e Catracas?/
      restaurant_base
    when /Cadastrar Restaurantes?/
      restaurant_base + '/new'
    when /Cadastrar Catracas?/
      turnstile_base + '/new'

    # Autentication paths
    when /^Autenticação de Admin$/ then new_admin_session_path
    when /^Autenticação do Operador$/ then new_operator_session_path
    when /^Autenticação do Estudante$/ then new_student_session_path
    when /^Configuração de Ponto$/ then new_access_point_path
    when /^Portal do Estudante$/ then student_portal_path
    when /^Terminal de Validação$/ then access_point_path

    when /^Recarga de Saldo$/ then new_recharge_path
    when /^Extrato e Histórico de Refeições$/ then statement_path

    when /^Cadastro Estudantil$/ then student_session_signup_path

    else
      raise "Can't find mapping from \"#{page_alias}\" to a path.\n" +
            "Now, go and add a mapping in #{__FILE__}"
    end
  end

  def model_path_to(model_name, page_type, options = {})
    resulting_path = '/'
    case model_name
    when /restaurants?/
      resulting_path += "admin/restaurants/"
    when /turnstiles?/
      resulting_path += "admin/turnstiles/"
    else
      raise "Can't find mapping from \"#{model_name}\" to a model.\n" +
            "Now, go and add a mapping in #{__FILE__}"
    end
    case page_type
    when /edit/
      resulting_path += options[:model].id.to_s
      resulting_path += "/edit"
    else
      raise "Can't find mapping from \"#{page_type}\" to a page type.\n" +
            "Now, go and add a mapping in #{__FILE__}"
    end
    resulting_path
  end
end

World(NavigationHelpers)
