require "test_helper"

class MenuCatalogTest < ActiveSupport::TestCase
  self.fixture_table_names = []

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
end
