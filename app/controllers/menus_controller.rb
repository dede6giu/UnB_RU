class MenusController < ApplicationController
  def show
    @catalog = MenuCatalog.new
    @today = Time.current.wday
    @selected_weekday = selected_weekday
    @weekday_name = @catalog.weekdays[@selected_weekday]

    if params[:weekday].present?
      @menus = @catalog.menus_for(@selected_weekday)
    else
      @current_meal_key = @catalog.current_meal_at
      @menus = @current_meal_key ? @catalog.menus_for(@selected_weekday).select { |menu| menu[:key] == @current_meal_key } : []
    end
  end

  private

  def selected_weekday
    value = params[:weekday]
    return @today unless value.present? && value.match?(/\A[0-6]\z/)

    value.to_i
  end
end
