require "rails_helper"

RSpec.describe "AccessPoints", type: :request do
  describe "GET /access_points/new" do
    it "mostra a página Configuração de Ponto" do
      get access_points_new_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Configuração de Ponto")
    end
  end
end
