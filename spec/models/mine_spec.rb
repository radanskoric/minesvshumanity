require 'rails_helper'

RSpec.describe Mine, type: :model do
  describe "#to_coordinate" do
    it "returns a coordinate object" do
      expect(Mine.new(x: 1, y: 2).to_coordinate).to eq Minesweeper::Coordinate.new(1, 2)
    end
  end
end
