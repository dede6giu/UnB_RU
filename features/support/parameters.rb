module ModelParameters
  def list_parameter_names(model_name)
    case model_name
    when /restaurants?/
      [ :name, :campus ]
    when /turnstiles?/
      [ :name, :operation, :restaurant_id ]
    else
      raise "Can't find mapping from \"#{model_name}\" to a model.\n" +
            "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(ModelParameters)
