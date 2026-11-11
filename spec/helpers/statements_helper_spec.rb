require "rails_helper"

RSpec.describe StatementsHelper, type: :helper do
  it "dá o nome do período, e sem período ou com um que não existe usa o padrão" do
    expect(helper.period_label("this_month")).to eq("Este mês")
    expect(helper.period_label("all")).to eq("Todo o período")
    expect(helper.period_label(nil)).to eq("Últimos 30 dias")
    expect(helper.period_label("xyz")).to eq("Últimos 30 dias")
  end

  it "dá o nome do tipo, e sem tipo ou com um que não existe usa o padrão" do
    expect(helper.type_label("credit")).to eq("Recargas")
    expect(helper.type_label("meal")).to eq("Refeições")
    expect(helper.type_label(nil)).to eq("Todos")
    expect(helper.type_label("xyz")).to eq("Todos")
  end
end
