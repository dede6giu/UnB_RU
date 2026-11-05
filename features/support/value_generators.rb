module ValuesGenerator
  def valid_value(field, avoid=[])
    case field
    when "restaurant_name",
      "restaurant_campus"
      vg_not_empty_string(avoid)
    else
      raise "Can't find mapping from \"#{field}\" to a valid_value method.\n" +
            "Now, go and add a mapping in #{__FILE__}"
    end
  end

  def invalid_value(field)
    case field
    when "restaurant_name",
      "restaurant_campus"
      vg_empty_string
    else
      raise "Can't find mapping from \"#{field}\" to a invalid_value method.\n" +
            "Now, go and add a mapping in #{__FILE__}"
    end
  end

  def create_models(model_name, amount=100)
    amount.times do
      case model_name
      when /restaurants?/
        Restaurant.create(name: vg_not_empty_string, campus: vg_not_empty_string)
      else
        raise "Can't find mapping from \"#{model_name}\" to a model.\n" +
              "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end

  def get_models(model_name)
    case model_name
    when /restaurants?/
      Restaurant.order("RANDOM()").first
    else
      raise "Can't find mapping from \"#{model_name}\" to a model.\n" +
            "Now, go and add a mapping in #{__FILE__}"
    end
  end

  def get_another(model_name, id)

    case model_name
    when /restaurants?/
      Restaurant.where("id != #{id}").order("RANDOM()").first
    else
      raise "Can't find mapping from \"#{model_name}\" to a model.\n" +
            "Now, go and add a mapping in #{__FILE__}"
    end
  end

  def parametrize_form_label(form_label)
    case form_label
    when /restaurant_name/
      "name"
    when /restaurant_campus/
      "campus"
    else
      raise "Can't find mapping from \"#{form_label}\" to a model's parameter.\n" +
            "Now, go and add a mapping in #{__FILE__}"
    end
  end

  def get_all_parameter_values(model_name, form_label)
    case model_name
    when /restaurants?/
      Restaurant.distinct.pluck(parametrize_form_label(form_label).intern)
    end
  end

  def vg_not_empty_string(avoid=[])
    string_size = Random.new.rand(30.0) + 1
    begin
      result = rand(36**string_size).to_s(36)
    end unless avoid.include?(result)
    result
  end

  def vg_empty_string
    ""
  end
end


World(ValuesGenerator)