# Traduz nomes de páginas usados nos cenários para as rotas reais da aplicação.
module NavigationHelpers
  def path_to(page_name)
    case page_name
    when /^Autenticação de Admin$/ then admin_sessions_new_path
    when /^Autenticação do Operador$/ then operator_sessions_new_path
    when /^Autenticação do Estudante$/ then student_sessions_new_path
    when /^Pontos de Acesso$/ then access_points_new_path
    when /^Portal do Estudante$/ then student_portal_new_path
    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" \
            "Add the mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)
