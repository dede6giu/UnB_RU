module ValuesGenerator
  def valid_value(field, avoid = [])
    case field
    when "restaurant_name", "restaurant_campus", "student_name"
      vg_rand_string(avoid)
    when "turnstile_name"
      vg_rand_string(avoid)
    when "turnstile_operation"
      %w[ Inativa Ativa Operando FastPass ].sample
    when /^student_user$/
      vg_student_user
    when /^student_password$/
      vg_rand_string(avoid, 8)
    when /-user$/
      @conta[:user]
    when /-pass$/
      @password
    when "credit-amount"
      "5"
    when "card-number"
      "4111111111111111"
    when "card-expire"
      "12/99"
    when "card-secure"
      "123"
    else
      pending "Can't find mapping from \"#{field}\" to a valid_value method.\n" +
            "Now, go and add a mapping in #{__FILE__}"
    end
  end

  def invalid_value(field)
    case field
    when "restaurant_name", "restaurant_campus", "turnstile_name", "student_name"
      vg_empty_string
    when /^student_user$/
      vg_student_user_invalid
    when /^student_password$/
      vg_rand_string([], 1, 8)
    when /-user$/
      "0000000015"
    when /-pass$/
      "000000"
    when "credit-amount"
      "abc"
    when "card-number"
      "4111"
    when "card-expire"
      "01/20"
    when "card-secure"
      "12"
    else
      pending "Can't find mapping from \"#{field}\" to a invalid_value method.\n" +
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
        Restaurant.create(name: vg_rand_string, campus: vg_rand_string)
      when /turnstiles?/
        Turnstile.create(name: vg_rand_string(avoid=options[:avoid][:name]),
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

  def vg_rand_string(avoid = [], min_size = 1, max_size = 30)
    if avoid == nil then avoid = [] end
    string_size = Random.new.rand(max_size) + min_size
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

  def vg_student_user(avoid=[])
    if avoid == nil then avoid = [] end
    begin
      year = Random.new.rand(26)
      if year < 10
        year = "0" + year.to_s
      else
        year = year.to_s
      end
      semester = (Random.new.rand(2) + 1).to_s + "0"
      number = Random.new.rand(100000).to_s
      while number.size < 5 do number = "0" + number end
      matricula = year + semester + number
    end until avoid.exclude?(matricula)
    matricula
  end

  def vg_student_user_invalid(avoid=[])
    if avoid == nil then avoid = [] end
    begin
      result = vg_student_user(avoid: avoid)
    end until avoid.exclude?(result) and result =~ /\A(?:[01]\d|2[0-6])(?:10|20)\d{5}\z/
  end
end

World(ValuesGenerator)
