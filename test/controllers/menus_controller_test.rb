require "test_helper"

class MenusControllerTest < ActionDispatch::IntegrationTest
  self.fixture_table_names = []
  include ActiveSupport::Testing::TimeHelpers

  SERVING_CASES = {
    "cafe_da_manha" => [8, 0],
    "almoco" => [12, 0],
    "jantar" => [18, 0]
  }.freeze

  test "cardapio is publicly accessible and has the requested weekday selector" do
    get public_menu_url

    assert_response :success
    assert_select "h1", "Cardápio"
    assert_select "#cardapio-weekday option", 7
    assert_select 'link[rel="stylesheet"][href*="application"]'
    assert_select ".public-site-header"
    assert_select '.public-site-nav__link[aria-current="page"]', "Cardápio"
  end

  7.times do |weekday|
    test "selecting weekday #{weekday} shows all meals and their JSON content" do
      get public_menu_url(weekday: weekday)

      assert_response :success
      assert_select "h2", MenuCatalog::WEEKDAYS[weekday].last
      assert_select ".meal-card", 3
      MenuCatalog::MEALS.each { |_key, label| assert_select ".meal-card h3", label }
      first_json_value = MenuCatalog.new.menus_for(weekday).first[:content].values.flatten.compact.first
      assert_select ".meal-card", /#{Regexp.escape(first_json_value)}/
    end
  end

  SERVING_CASES.each do |meal_key, (hour, minute)|
    7.times do |weekday|
      test "shows #{meal_key} for weekday #{weekday} during its specified serving time" do
        travel_to(Time.zone.local(2026, 11, 1 + weekday, hour, minute)) do
          get public_menu_url
        end

        assert_response :success
        assert_select ".meal-card--current h3", MenuCatalog::MEALS.assoc(meal_key).last
        assert_select ".meal-card", 1
      end
    end
  end

  test "shows the no current meal message outside specified serving times" do
    travel_to(Time.zone.local(2026, 11, 1, 10, 0)) do
      get public_menu_url
    end

    assert_response :success
    assert_select ".meal-card", 0
    assert_select ".public-menu__empty", /Não há uma refeição sendo servida/
  end
end
