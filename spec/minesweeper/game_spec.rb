require "spec_helper"

require "timeout"

require "minesweeper/game"
require "minesweeper/board"

RSpec.describe Minesweeper::Game do
  let(:mines) { [coord(1, 0), coord(3, 1), coord(3, 2), coord(5,1), coord(5,2)] }
  let(:board) { Minesweeper::Board.new(8, 3, mines) }
  let(:game) { described_class.new(board) }

  it "allows to play a game and win" do
    expect(ascii_render(game)).to eq <<~BOARD
      ########
      ########
      ########
    BOARD
    expect(game.status).to eq :play

    expect(game.reveal(coord(0, 1))).to eq :play
    expect(ascii_render(game)).to eq <<~BOARD
      ########
      1#######
      ########
    BOARD

    expect(game.reveal(coord(2, 1))).to eq :play
    expect(ascii_render(game)).to eq <<~BOARD
      ########
      1#3#####
      ########
    BOARD

    expect(game.reveal(coord(7, 0))).to eq :play
    expect(ascii_render(game)).to eq <<~BOARD
      ######1_
      1#3###2_
      ######2_
    BOARD

    expect(game.reveal(coord(0, 2))).to eq :play
    expect(ascii_render(game)).to eq <<~BOARD
      ######1_
      113###2_
      __2###2_
    BOARD

    game.reveal(coord(0, 0))
    game.reveal(coord(2, 0))
    game.reveal(coord(3, 0))
    game.reveal(coord(4, 0))
    game.reveal(coord(5, 0))
    expect(game.reveal(coord(4, 1))).to eq :play
    expect(ascii_render(game)).to eq <<~BOARD
      1#21211_
      113#4#2_
      __2###2_
    BOARD
    expect(game.status).to eq :play

    expect(game.reveal(coord(4, 2))).to eq :win
    expect(ascii_render(game)).to eq <<~BOARD
      1#21211_
      113#4#2_
      __2#4#2_
    BOARD
    expect(game.status).to eq :win
  end

  it "allows to play a game and lose" do
    expect(game.reveal(coord(0, 1))).to eq :play
    expect(ascii_render(game)).to eq <<~BOARD
      ########
      1#######
      ########
    BOARD
    expect(game.status).to eq :play

    expect(game.reveal(coord(1, 0))).to eq :lose
    expect(ascii_render(game)).to eq <<~BOARD
      #*######
      1#######
      ########
    BOARD
    expect(game.status).to eq :lose
  end

  it "ignores further reveals after the game has finished" do
    expect(game.reveal(coord(1, 0))).to eq :lose
    expect(ascii_render(game)).to eq <<~BOARD
      #*######
      ########
      ########
    BOARD
    expect(game.status).to eq :lose

    expect(game.reveal(coord(0, 0))).to eq :lose
    expect(ascii_render(game)).to eq <<~BOARD
      #*######
      ########
      ########
    BOARD
    expect(game.status).to eq :lose
  end

  it "allows to mark cells as mines and prevent direct click on them" do
    game.reveal(coord(0, 0))
    expect(game.mines_left).to eq 5
    game.mark(coord(1, 0))
    expect(ascii_render(game)).to eq <<~BOARD
      1🚩######
      ########
      ########
    BOARD
    expect(game.mines_left).to eq 4

    expect(game.reveal(coord(1, 0))).to eq :play
    expect(ascii_render(game)).to eq <<~BOARD
      1#######
      ########
      ########
    BOARD

    expect(game.reveal(coord(1, 0))).to eq :lose
  end

  it "will flood over incorrectly placed markers" do
    game.mark(coord(7, 1))
    expect(ascii_render(game)).to eq <<~BOARD
      ########
      #######🚩
      ########
    BOARD
    game.reveal(coord(7, 0))
    expect(ascii_render(game)).to eq <<~BOARD
      ######1_
      ######2_
      ######2_
    BOARD
  end

  it "works efficiently with huge boards" do
    game = Minesweeper::Game.new(Minesweeper::Board.new(200, 200, [coord(1, 1)]))

    expect {
      Timeout.timeout(0.5) do
        game.reveal(coord(50, 50))
      end
    }.not_to raise_error
  end
end
