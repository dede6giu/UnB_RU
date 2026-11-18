class HomeController < ApplicationController
  # Mostra o cardápio da próxima refeição e a entrada de cada perfil
  def show
    if session[:student_id].present?
      redirect_to student_portal_path
    else
      catalog = MenuCatalog.new
      @widget_menu = catalog.widget_menu_at
      @widget_weekday_name = catalog.weekdays[@widget_menu[:weekday_index]]
    end
  end
end
