require "test_helper"

class MenusControllerTest < ActionDispatch::IntegrationTest
  self.fixture_table_names = []
  include ActiveSupport::Testing::TimeHelpers

  SERVING_CASES = {
    "cafe_da_manha" => [ 8, 0 ],
    "almoco" => [ 12, 0 ],
    "jantar" => [ 18, 0 ]
  }.freeze

  test "cardapio is publicly accessible and has the requested weekday selector" do
    get public_menu_url

    assert_response :success
    assert_select "h1", "Cardápio"
    assert_select "#cardapio-weekday option", 7
    assert_select 'link[rel="stylesheet"][href*="application"]'
    assert_select "header"
    assert_select '.nav-link.active[aria-current="page"]', "Cardápio"
  end

  7.times do |weekday|
    test "selecting weekday #{weekday} shows all meals and their JSON content" do
      get public_menu_url(weekday: weekday)

      assert_response :success
      assert_select "h2", MenuCatalog::WEEKDAYS[weekday].last
      assert_select "#selected-menus .card", 3
      MenuCatalog::MEALS.each { |_key, label| assert_select "#selected-menus .card h3", label }
      first_json_value = MenuCatalog.new.menus_for(weekday).first[:content].values.flatten.compact.first
      assert_select "#selected-menus .card", /#{Regexp.escape(first_json_value)}/
    end
  end

  SERVING_CASES.each do |meal_key, (hour, minute)|
    7.times do |weekday|
      test "shows #{meal_key} for weekday #{weekday} during its specified serving time" do
        travel_to(Time.zone.local(2026, 11, 1 + weekday, hour, minute)) do
          get public_menu_url
        end

        assert_response :success
        assert_select "#selected-menus .card[data-current=true] h3", MenuCatalog::MEALS.assoc(meal_key).last
        assert_select "#selected-menus .card", 1
      end
    end
  end

  test "shows the no current meal message outside specified serving times" do
    travel_to(Time.zone.local(2026, 11, 1, 10, 0)) do
      get public_menu_url
    end

    assert_response :success
    assert_select "#selected-menus", false
    assert_select "#no-current-meal.alert", /Não há uma refeição sendo servida/
  end

  test "widget renders the current dinner and its menu content" do
    travel_to(Time.zone.local(2026, 11, 5, 18, 0)) do
      get public_menu_url
    end

    assert_response :success
    assert_select "#meal-widget", /Sendo servida agora/
    assert_select "#meal-widget h2", "Janta"
    assert_select "#meal-widget .card", /Suíno com cebola caramelizada/
  end

  test "widget renders the next weekday breakfast after dinner" do
    travel_to(Time.zone.local(2026, 11, 7, 20, 0)) do
      get public_menu_url
    end

    assert_response :success
    assert_select "#meal-widget", /Próxima refeição/
    assert_select "#meal-widget h2", "Café da Manhã"
    assert_select "#meal-widget", /Domingo/
  end

  test "widget follows the feature scenario before breakfast and shows lunch" do
    travel_to(Time.zone.local(2026, 11, 5, 6, 0)) do
      get public_menu_url
    end

    assert_response :success
    assert_select "#meal-widget", /Próxima refeição/
    assert_select "#meal-widget h2", "Almoço"
  end
end
