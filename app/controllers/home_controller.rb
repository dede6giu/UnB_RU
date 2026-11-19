class HomeController < ApplicationController
  # Mostra o cardápio da próxima refeição e a entrada de cada perfil
  def show
    catalog = MenuCatalog.new
    @widget_menu = catalog.widget_menu_at
    @widget_weekday_name = catalog.weekdays[@widget_menu[:weekday_index]]
  end
end
