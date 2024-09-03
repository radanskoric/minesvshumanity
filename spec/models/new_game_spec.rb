require 'rails_helper'

RSpec.describe NewGame, type: :model do
  fixtures :accounts, :matches

  let(:owner) { accounts(:freddie) }
  let(:match) { matches(:public) }

  it "creates a new game with a board" do
    game = described_class.new(width: 20, height: 10, mines: 15, match:).save
    expect(game.status).to eq "play"
    expect(game.board).to be_present
    expect(game.board.width).to eq 20
    expect(game.board.height).to eq 10
    expect(game.board.mines.size).to eq(15)
    expect(game.clicks).to be_empty
  end

  it "validates width" do
    model = described_class.new(width: 51)
    model.validate
    expect(model.errors).to have_key(:width)
  end

  it "validates height" do
    model = described_class.new(height: 51)
    model.validate
    expect(model.errors).to have_key(:height)
  end

  it "validates mines" do
    model = described_class.new(mines: 501)
    model.validate
    expect(model.errors).to have_key(:mines)
  end

  it "fails if trying to start an invalid game" do
    expect(described_class.new(width: 500).save).to eq false
  end

  it "doesn't create a new game if it's not valid" do
    expect { described_class.new(width: 500).save }.not_to change(Game, :count)
  end

  it "is not possible to start two public games at the same time" do
    described_class.new(width: 5, height: 5, mines: 2, match:).save
    expect { described_class.new(width: 5, height: 5, mines: 2, match:).save }.to raise_error(ActiveRecord::RecordNotUnique)
  end

  it "creates a private game if owner is set" do
    expect do
      described_class.new(width: 5, height: 5, mines: 2, owner:).save
    end.to change(owner.games, :count).by(1)
  end

  it "allows creating a private game while a public one is in play" do
    described_class.new(width: 5, height: 5, mines: 2, match:).save
    expect { described_class.new(width: 5, height: 5, mines: 2, owner:).save }.to change(Game, :count).by(1)
  end

  context "with a fair start flag" do
    let(:new_game) { described_class.new(width: 5, height: 5, mines: 10, fair_start: true, match:).save }

    it "marks the game as fair start" do
      expect(new_game.fair_start).to be true
    end

    it "creates a new game with the first click already generated on blank cell" do
      expect(new_game.clicks.size).to eq 1
      expect(new_game.status).to eq "play"
    end
  end

  describe ".model_name" do
    it "mimicks the underyling Game model" do
      expect(described_class.model_name.name).to eq Game.model_name.name
    end
  end

  describe ".create!" do
    it "creates a new" do
      expect { described_class.create(match:) }.to change(Game, :count).by(1)
    end
  end
end
