module ValuesGenerator
  def valid_value(field)
    case field
    when "restaurant_name",
      "restaurant_campus"
      not_empty_string
    else
      raise "Can't find mapping from \"#{field}\" to a valid_value method.\n" +
            "Now, go and add a mapping in #{__FILE__}"
    end
  end

  def invalid_value(field)
    case field
    when "restaurant_name",
      "restaurant_campus"
      empty_string
    else
      raise "Can't find mapping from \"#{field}\" to a invalid_value method.\n" +
            "Now, go and add a mapping in #{__FILE__}"
    end
  end

  def not_empty_string
    string_size = Random.new.rand(30.0) + 1
    rand(36**string_size).to_s(36)
  end

  def empty_string
    nil
  end
end


World(ValuesGenerator)