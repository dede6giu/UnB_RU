module NavigationHelpers
  def path_to(page_alias)
    restaurant_base = '/admin/restaurants'

    case page_alias
    when /Index/
      '/'

    # Restaurant paths
    when /Gestão de Restaurantes? e Catracas?/
      restaurant_base
    when /Cadastrar Restaurantes?/
      restaurant_base + '/new'

    else
      raise "Can't find mapping from \"#{page_alias}\" to a path.\n" +
            "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)