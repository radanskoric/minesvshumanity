require 'rails_helper'

RSpec.describe "Play the game", type: :system do
  let(:game_with_one_mine) do
    Game.create!(
      board: Board.create!(
        width: 10,
        height: 10,
        mines: [Minesweeper::Coordinate.new(1, 1)]
      )
    )
  end

  it "allows creating clicks" do
    visit root_path

    within 'table.board' do
      first('a', text: '').click
    end

    expect(page).to have_content('1')
  end
end
