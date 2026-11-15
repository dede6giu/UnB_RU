class StudentPortalController < ApplicationController
  include StudentAuthentication

  def show
    catalog = MenuCatalog.new
    @widget_menu = catalog.widget_menu_at
    @widget_weekday_name = catalog.weekdays[@widget_menu[:weekday_index]]
  end
end
