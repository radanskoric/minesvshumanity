require 'rails_helper'

RSpec.describe Click, type: :model do
  describe "#to_coordinate" do
    it "returns a coordinate object" do
      expect(Mine.new(x: 1, y: 2).to_coordinate).to eq Minesweeper::Coordinate.new(1, 2)
    end
  end

  it "updates the game's timestamp" do
    game = Game.start_new(width: 5, height: 3, mines: 2)
    expect { game.clicks.create!(x: 1, y: 1) }.to change { game.reload.updated_at }
  end
end
