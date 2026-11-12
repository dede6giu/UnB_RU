require "test_helper"

class MenuCatalogTest < ActiveSupport::TestCase
  self.fixture_table_names = []
  include ActiveSupport::Testing::TimeHelpers

  test "loads all seven weekdays and three meals from the existing JSON catalog" do
    catalog = MenuCatalog.new

    assert_equal 7, catalog.weekdays.length
    7.times do |weekday|
      assert_equal MenuCatalog::MEALS.map(&:last), catalog.menus_for(weekday).map { |menu| menu[:label] }
    end
  end

  test "preserves menu contents from the JSON source" do
    monday = MenuCatalog.new.menus_for(1)

    assert_equal "Pão francês", monday.first[:content].fetch("panificacao").first
    assert_equal "Frango assado com manjericão", monday.second[:content].fetch("prato_principal_padrao")
  end

  { "cafe_da_manha" => [8, 0], "almoco" => [12, 0], "jantar" => [18, 0] }.each do |meal_key, (hour, minute)|
    test "widget selects current #{meal_key} across all weekdays" do
      7.times do |weekday|
        time = Time.zone.local(2026, 11, 1 + weekday, hour, minute)
        menu = MenuCatalog.new.widget_menu_at(time)

        assert_equal weekday, menu[:weekday_index]
        assert_equal meal_key, menu[:key]
        assert menu[:current]
      end
    end
  end

  {
    "before breakfast" => [6, 0, "almoco", 0],
    "between breakfast and lunch" => [10, 0, "almoco", 0],
    "between lunch and dinner" => [15, 0, "jantar", 0],
    "after dinner" => [20, 0, "cafe_da_manha", 1]
  }.each do |period, (hour, minute, expected_meal, day_offset)|
    test "widget selects #{expected_meal} #{period} across all weekdays" do
      7.times do |weekday|
        time = Time.zone.local(2026, 11, 1 + weekday, hour, minute)
        menu = MenuCatalog.new.widget_menu_at(time)

        assert_equal expected_meal, menu[:key]
        assert_equal (weekday + day_offset) % 7, menu[:weekday_index]
        assert_not menu[:current]
      end
    end
  end
end
