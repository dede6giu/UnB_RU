require "rails_helper"

RSpec.describe "Menus", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  describe "GET /menu" do
    context "sem dia escolhido e fora do horário das refeições" do
      it "mostra o aviso de que nenhuma refeição está sendo servida" do
        travel_to Time.zone.local(2026, 11, 25, 10, 0) do
          get public_menu_path

          expect(response).to have_http_status(:success)
          expect(response.body).to include("Não há uma refeição sendo servida neste momento.")
        end
      end
    end

    context "sem dia escolhido e dentro do horário de uma refeição" do
      it "mostra o cardápio da refeição que está sendo servida" do
        travel_to Time.zone.local(2026, 11, 25, 12, 0) do
          get public_menu_path

          expect(response).to have_http_status(:success)
          expect(response.body).to include('id="selected-menus"')
          expect(response.body).not_to include("Não há uma refeição sendo servida neste momento.")
        end
      end
    end

    context "com dia da semana válido" do
      it "mostra os cardápios do dia escolhido, mesmo fora do horário" do
        travel_to Time.zone.local(2026, 11, 25, 10, 0) do
          get public_menu_path, params: { weekday: "1" }

          expect(response).to have_http_status(:success)
          expect(response.body).to include("Segunda-feira")
          expect(response.body).to include('id="selected-menus"')
          expect(response.body).not_to include("Não há uma refeição sendo servida neste momento.")
        end
      end
    end

    context "com dia da semana inválido" do
      it "ignora o dia e usa o dia de hoje" do
        travel_to Time.zone.local(2026, 11, 25, 10, 0) do
          get public_menu_path, params: { weekday: "9" }

          expect(response).to have_http_status(:success)
          expect(response.body).to include('<h2 id="selected-day" class="h2 fg-primary mb-3">Quarta-feira</h2>')
        end
      end
    end
  end
end
