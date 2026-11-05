# Traduz nomes de páginas usados nos cenários para as rotas reais da aplicação.
module NavigationHelpers
  def path_to(page_name)
    case page_name
    when /^Autenticação de Admin$/ then new_admin_session_path
    when /^Autenticação do Operador$/ then new_operator_session_path
    when /^Autenticação do Estudante$/ then new_student_session_path
    when /^Configuração de Ponto$/ then new_access_point_path
    when /^Portal do Estudante$/ then student_portal_path
    when /^Terminal de Validação$/ then access_point_path
    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" \
            "Add the mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)
