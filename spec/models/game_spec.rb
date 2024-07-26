require 'rails_helper'

RSpec.describe Game, type: :model do
  describe ".start_new" do
    it "creates a new game with a board" do
      game = described_class.start_new(20, 10, 15)
      expect(game.status).to eq "play"
      expect(game.board).to be_present
      expect(game.board.width).to eq 20
      expect(game.board.height).to eq 10
      expect(game.board.mines.size).to eq(15)
      expect(game.clicks).to be_empty
    end
  end

  describe ".current" do
    subject(:current) { described_class.current }

    before do
      # Create games in non play states
      described_class.start_new(5, 5, 2).update!(status: :win)
      described_class.start_new(5, 5, 2).update!(status: :lose)
    end

    it "returns the game in play state if it exists" do
      play_game = described_class.start_new(5, 5, 2)
      expect(current).to eq play_game
    end

    it "returns nil if it does not exist" do
      expect(current).to be_nil
    end
  end

  describe "#to_game_object" do
    it "returns a game object matching the game" do
      game_object = described_class.start_new(5, 3, 2).to_game_object
      expect(game_object).to be_a(Minesweeper::Game)
      expect(game_object.width).to eq 5
      expect(game_object.height).to eq 3
    end

    it "replays the clicks on the game object" do
      game = described_class.start_new(5, 3, 2)
      game.clicks.create!(x: 0, y: 0)
      game_object = game.to_game_object
      expect(game_object.cell(Minesweeper::Coordinate.new(0 , 0))).to be_present
    end
  end
end
