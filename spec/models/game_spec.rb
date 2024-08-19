require 'rails_helper'

RSpec.describe Game, type: :model do
  fixtures :accounts

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
    let(:owner) { accounts(:freddie) }

    it "creates a new game with a board" do
      game = described_class.start_new(20, 10, 15)
      expect(game.status).to eq "play"
      expect(game.board).to be_present
      expect(game.board.width).to eq 20
      expect(game.board.height).to eq 10
      expect(game.board.mines.size).to eq(15)
      expect(game.clicks).to be_empty
    end

    it "is not possible to start two public games at the same time" do
      described_class.start_new(5, 5, 2)
      expect { described_class.start_new(5, 5, 2) }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it "creates a private game if owner is set" do
      expect do
        described_class.start_new(5, 5, 2, owner:)
      end.to change(owner.games, :count).by(1)
    end

    it "allows creating a private game while a public one is in play" do
      described_class.start_new(5, 5, 2)
      expect { described_class.start_new(5, 5, 2, owner:) }.to change(Game, :count).by(1)
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

    it "ignores private games" do
      described_class.start_new(5, 5, 2, owner: accounts(:freddie))
      described_class.start_new(5, 5, 2, owner: accounts(:brian))
      public_game = described_class.start_new(5, 5, 2)
      expect(current).to eq public_game
    end

    it "returns nil if it does not exist" do
      expect(current).to be_nil
    end
  end

  describe "#finished?" do
    it "returns true for game in win state" do
      expect(Game.new(status: :win)).to be_finished
    end

    it "returns true for game in lose state" do
      expect(Game.new(status: :lose)).to be_finished
    end

    it "returns false for game in false state" do
      expect(Game.new(status: :play)).not_to be_finished
    end
  end

  describe "#communal?" do
    it "returns true for games with no owner" do
      expect(Game.new(owner: nil)).to be_communal
    end

    it "returns false for games with an owner" do
      expect(Game.new(owner: accounts(:freddie))).not_to be_communal
    end
  end

  describe "#private?" do
    it "returns true for games with an owner" do
      expect(Game.new(owner: accounts(:freddie))).to be_private
    end

    it "returns false for games with no owner" do
      expect(Game.new(owner: nil)).not_to be_private
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

    it "replays mine marking clicks as mine markers" do
      game.clicks.create!(x: 1, y: 1, mark_as_mine: true)
      game_object = game.to_game_object
      expect(game_object.cell(Minesweeper::Coordinate.new(1, 1))).to be_a Minesweeper::Game::Marker
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

  describe "#click!" do
    it "stores the new click" do
      game.click!(x: 2, y: 1)
      expect(game.clicks.size).to eq 1
      expect(game.clicks.first.slice(:x, :y)).to eq({ "x" => 2, "y" => 1 })
    end

    it "stores the mine marking click" do
      game.click!(x: 2, y: 1, mark_as_mine: true)
      expect(game.clicks.size).to eq 1
      expect(game.clicks.first.mark_as_mine).to eq true
    end

    it "keeps status as play when play continues" do
      game.click!(x: 2, y: 1)
      expect(game.status).to eq "play"
    end

    it "updates status to lose when game was lost" do
      game.click!(x: 2, y: 2)
      expect(game.status).to eq "lose"
    end

    it "updates status to win when game was won" do
      game.click!(x: 5, y: 5)
      expect(game.status).to eq "win"
    end

    it "returns a game object" do
      result = game.click!(x: 2, y: 1)
      expect(result).to be_a(Minesweeper::Game)
    end
  end
end
