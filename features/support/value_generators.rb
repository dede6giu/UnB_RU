module ValuesGenerator
  def valid_value(field, avoid = [])
    case field
    when "restaurant_name", "restaurant_campus"
      vg_not_empty_string(avoid)
    when "turnstile_name"
      vg_not_empty_string(avoid)
    when "turnstile_operation"
      %w[ Inativa Ativa Operando FastPass ].sample
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
    when "turnstile_name"
      vg_empty_string
    else
      raise "Can't find mapping from \"#{field}\" to a invalid_value method.\n" +
            "Now, go and add a mapping in #{__FILE__}"
    end
  end

  def create_models(model_name, amount = 100, options = {})
    if options[:conditions] != nil
      options[:avoid] = avoid_mapping(options[:conditions])
    else
      options[:avoid] = {}
    end
    amount.times do
      case model_name
      when /restaurants?/
        Restaurant.create(name: vg_not_empty_string, campus: vg_not_empty_string)
      when /turnstiles?/
        Turnstile.create(name: vg_not_empty_string(avoid=options[:avoid][:name]),
                         operation: vg_operation_mode(avoid=options[:avoid][:operation]),
                         restaurant_id: Restaurant.all.order("RANDOM()").first.id)
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
    when /turnstiles?/
      Turnstile.order("RANDOM()").first
    else
      raise "Can't find mapping from \"#{model_name}\" to a model.\n" +
            "Now, go and add a mapping in #{__FILE__}"
    end
  end

  def get_another(model_name, id)
    case model_name
    when /restaurants?/
      Restaurant.where("id != #{id}").order("RANDOM()").first
    when /turnstiles?/
      Turnstile.where("id != #{id}").order("RANDOM()").first
    else
      raise "Can't find mapping from \"#{model_name}\" to a model.\n" +
            "Now, go and add a mapping in #{__FILE__}"
    end
  end

  def parametrize_form_label(form_label)
    form_label =~ /_(.*)/
    $1
  end

  def get_all_parameter_values(model_name, form_label)
    case model_name
    when /restaurants?/
      Restaurant.distinct.pluck(parametrize_form_label(form_label).intern)
    when /turnstiles?/
      Turnstile.pluck(parametrize_form_label(form_label).intern)
    else
      raise "Can't find mapping from \"#{model_name}\" to a model's name.\n" +
            "Now, go and add a mapping in #{__FILE__}"
    end
  end

  def avoid_mapping(conditions)
    result = {}
    if conditions.is_a?(String) then conditions = [ conditions ] end
    conditions.each do |condition|
      case condition
      when /^operational$/
        result[:operation] = %w[Inativa Ativa]
      when /^non-operational$/
        result[:operation] = %w[Operando FastPass]
      else
        raise "Can't find mapping from \"#{condition}\" to a model's value condition.\n" +
              "Now, go and add a mapping in #{__FILE__}"
      end
    end
    result
  end

  def want_mapping(conditions)
    result = {}
    if conditions.is_a?(String) then conditions = [ conditions ] end
    conditions.each do |condition|
      case condition
      when /^operational$/
        result[:operation] = %w[Operando FastPass]
      when /^non-operational$/
        result[:operation] = %w[Inativa Ativa]
      else
        raise "Can't find mapping from \"#{condition}\" to a model's value condition.\n" +
              "Now, go and add a mapping in #{__FILE__}"
      end
    end
    result
  end

  def vg_not_empty_string(avoid = [])
    if avoid == nil then avoid = [] end
    string_size = Random.new.rand(30.0) + 1
    begin
      result = rand(36**string_size).to_s(36)
    end until avoid.exclude?(result)
    result
  end

  def vg_empty_string
    ""
  end

  def vg_operation_mode(avoid = [])
    if avoid == nil then avoid = [] end
    operation_modes = %w[Inativa Ativa Operando FastPass]
    begin
      result = operation_modes[rand(4)]
    end until avoid.exclude?(result)
    result
  end
end

World(ValuesGenerator)
