require 'rails_helper'

RSpec.describe Board, type: :model do
  describe "#to_game_object" do
    it "returns a game object matching the game" do
      game_object = Game.start_new(5, 3, 2).board.to_game_object
      expect(game_object).to be_a(Minesweeper::Board)
      expect(game_object.width).to eq 5
      expect(game_object.height).to eq 3
      expect(game_object.mines.size).to eq 2
    end
  end
end
