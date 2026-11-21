# Página inicial do sistema, aberta para todo mundo (sem login).
class HomeController < ApplicationController
  ##
  # GET /
  #
  # Mostra o cardápio da próxima refeição (ou da que está sendo servida) e a entrada de cada perfil:
  # estudante (login e cadastro), operador e admin.
  #
  # Não recebe argumentos e não altera o banco; só lê o cardápio do cardapio.json (MenuCatalog).
  def show
    catalog = MenuCatalog.new
    @widget_menu = catalog.widget_menu_at
    @widget_weekday_name = catalog.weekdays[@widget_menu[:weekday_index]]
  end
end
