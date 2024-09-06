require 'rails_helper'

RSpec.describe "Privacies", type: :request do
  describe "GET /show" do
    it "returns http success" do
      get "/privacy"
      expect(response).to have_http_status(:success)
    end
  end

end
