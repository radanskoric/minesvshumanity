require 'rails_helper'

RSpec.describe Game, type: :model do
  subject(:game) do
    # Create with just two mines to simplify testing.
    Game.create!(
      board: Board.create!(
        width: 10,
        height: 12,
        mines: [Mine.new(x: 2, y: 2), Mine.new(x: 7, y: 7)]
      )
    )
  end

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

    it "is not possible to start two games at the same time" do
      described_class.start_new(5, 5, 2)
      expect { described_class.start_new(5, 5, 2) }.to raise_error(ActiveRecord::RecordNotUnique)
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
      game_object = game.to_game_object
      expect(game_object).to be_a(Minesweeper::Game)
      expect(game_object.width).to eq 10
      expect(game_object.height).to eq 12
    end

    it "replays the clicks on the game object" do
      game.clicks.create!(x: 1, y: 1)
      game_object = game.to_game_object
      expect(game_object.cell(Minesweeper::Coordinate.new(1, 1))).to be_present
    end

    it "is resistant to concurrent clicks" do
      game.clicks.load # Warm up the cache.
      Click.create!(game: game, x: 2, y: 1)
      game.clicks << Click.new(x: 1, y: 1)

      game_object = game.to_game_object
      # Verify both clicks are recorded on the game object.
      expect(game_object.cell(Minesweeper::Coordinate.new(1, 1))).to be_present
      expect(game_object.cell(Minesweeper::Coordinate.new(2, 1))).to be_present
    end
  end

  describe "#reveal!" do
    it "stores the new click" do
      game.reveal!(x: 2, y: 1)
      expect(game.clicks.size).to eq 1
      expect(game.clicks.first.slice(:x, :y)).to eq({ "x" => 2, "y" => 1 })
    end

    it "keeps status as play when play continues" do
      game.reveal!(x: 2, y: 1)
      expect(game.status).to eq "play"
    end

    it "updates status to lose when game was lost" do
      game.reveal!(x: 2, y: 2)
      expect(game.status).to eq "lose"
    end

    it "updates status to win when game was won" do
      game.reveal!(x: 5, y: 5)
      expect(game.status).to eq "win"
    end

    it "returns a game object" do
      result = game.reveal!(x: 2, y: 1)
      expect(result).to be_a(Minesweeper::Game)
    end
  end
end
