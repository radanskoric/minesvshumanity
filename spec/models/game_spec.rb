require 'rails_helper'

RSpec.describe Game, type: :model do
  fixtures :accounts

  subject(:game) { Game.create!(board:) }
  let(:board) do
    # Just two mines to simplify testing.
    Board.create!(
      width: 10,
      height: 12,
      mines: [Mine.new(x: 2, y: 2), Mine.new(x: 7, y: 7)]
    )
  end

  describe ".current" do
    subject(:current) { described_class.current }

    before do
      # Create games in non play states
      NewGame.create(width: 5, height: 5, mines: 2).update!(status: :win)
      NewGame.create(width: 5, height: 5, mines: 2).update!(status: :lose)
    end

    it "returns the game in play state if it exists" do
      play_game = NewGame.create(width: 5, height: 5, mines: 2)
      expect(current).to eq play_game
    end

    it "ignores private games" do
      NewGame.create(width: 5, height: 5, mines: 2, owner: accounts(:freddie))
      NewGame.create(width: 5, height: 5, mines: 2, owner: accounts(:brian))
      public_game = NewGame.create(width: 5, height: 5, mines: 2)
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

  describe "#replay_for" do
    before { game } # make sure it's created

    let(:account) { accounts(:freddie) }

    it "creates a game" do
      expect { game.replay_for(accounts(:freddie)) }.to change(Game, :count).by(1)
    end

    it "keeps the same board but sets the new owner" do
      new_game = game.replay_for(account)
      expect(new_game.board).to eq game.board
      expect(new_game.owner).to eq account
    end

    context "with a fair start game" do
      let(:fair_start_game) { NewGame.create(width: 5, height: 5, mines: 2, fair_start: true, owner: account) }

      it "makes the new game fair start with same first click" do
        new_game = fair_start_game.replay_for(account)

        expect(new_game.clicks.size).to eq 1
        expect(new_game.clicks.first.slice(:x, :y)).to eq(fair_start_game.clicks.first.slice(:x, :y))
        expect(new_game.fair_start).to be true
      end
    end
  end
end
