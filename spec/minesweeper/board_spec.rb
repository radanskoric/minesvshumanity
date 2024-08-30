require "spec_helper"

require "minesweeper/board"

RSpec.describe Minesweeper::Board do
  let(:full_3_2_board) { Enumerator::Product.new(0..2, 0..1).map { coord(_1, _2) } }

  def render_for(width, height, mines)
    ascii_render(described_class.new(width, height, mines))
  end

  it "calculates correctly when it's all mines" do
    expect(render_for(3, 2, full_3_2_board)).to eq <<~BOARD
      ***
      ***
    BOARD
  end

  it "calculates correctly when it's no mines" do
    expect(render_for(3, 2, [])).to eq <<~BOARD
      ___
      ___
    BOARD
  end

  it "calculates correctly with one mine" do
    expect(render_for(3, 2, [coord(0, 0)])).to eq <<~BOARD
      *1_
      11_
    BOARD
  end

  it "calculates correctly with two mines" do
    expect(render_for(3, 2, [coord(0, 0), coord(2, 0)])).to eq <<~BOARD
      *2*
      121
    BOARD
  end

  it "calculates correctly with just one empty field" do
    expect(render_for(3, 2, full_3_2_board - [coord(1, 1)])).to eq <<~BOARD
      ***
      *5*
    BOARD
  end

  it "calculates correctly with a more complex board" do
    expect(render_for(8, 4, [coord(1, 1), coord(3, 1), coord(3, 2), coord(5,1), coord(5,2), coord(5,3)])).to eq <<~BOARD
      1121211_
      1*3*4*2_
      113*5*3_
      __113*2_
    BOARD
  end

  describe ".generate_random" do
    it "can generate a random board" do
      expect { described_class.generate_random(3, 2, 1, fair_start: false) }.to_not raise_error
    end

    context "with fair_start option" do
      it "returns a click guaranteed to be a cell with no neighbouring mines" do
        10.times do
          board, coord = described_class.generate_random(3, 2, 1, fair_start: true)

          expect(board.cell(coord)).to eq(Minesweeper::Board::Empty.new(0))
        end
      end
    end
  end
end
