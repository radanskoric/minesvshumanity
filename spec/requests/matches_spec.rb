require 'rails_helper'

RSpec.describe "Matches", type: :request do
  fixtures :matches

  describe "GET /show" do
    it "returns http success" do
      get "/matches/#{matches(:public).id}"
      expect(response).to have_http_status(:success)
      expect(response.body).to include(matches(:public).name)
    end
  end

end
