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
