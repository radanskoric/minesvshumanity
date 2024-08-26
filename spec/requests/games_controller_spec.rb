require 'rails_helper'

RSpec.describe "Games Controller" do
  fixtures :accounts

  let(:account) { accounts(:freddie) }
  let(:public_game) { Game.create!(board:) }
  let(:private_game) { Game.create!(board:, owner: account) }
  let(:board) do
    Board.create!(
      width: 10,
      height: 10,
      mines: [Mine.new(x: 2, y: 2)],
    )
  end

  describe "show" do
    it "doesn't allow viewing other's private game" do
      post "/login", params: { email: accounts(:brian).email, password: "password"}

      get "/games/#{private_game.id}"

      expect(response).to be_not_found
    end
  end

  describe '#replay' do
    it "doesn't allow replaying an unfinished game" do
      post "/login", params: { email: account.email, password: "password" }

      post "/games/#{public_game.id}/replay"

      expect(response).to be_forbidden
    end
  end
end
