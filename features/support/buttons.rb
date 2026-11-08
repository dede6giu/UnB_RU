module ButtonPaths
  def button_path(button_alias)
    case button_alias
    when "create restaurant", "save restaurant",
      "create turnstile", "save turnstile"
      "commit"
    when "remove restaurant", "remove turnstile"
      "btn_destroy"
    else
      raise "Can't find mapping from \"#{button_alias}\" to a path.\n" +
            "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(ButtonPaths)