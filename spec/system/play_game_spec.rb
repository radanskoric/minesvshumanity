require 'rails_helper'

RSpec.describe "Play the game", type: :system do
  let!(:game_with_one_mine) do
    Game.create!(
      board: Board.create!(
        width: 10,
        height: 10,
        mines: [Mine.new(x: 2, y: 2)]
      )
    )
  end

  it "allows creating clicks" do
    visit root_path
    click_cell(1, 1)

    expect(page).to have_content('1')
  end

  it "correctly detects when game has been lost" do
    visit root_path
    click_cell(2, 2)

    expect(page).to have_content('Humanity lost')
  end

  it "correctly detects when game has been won" do
    visit root_path
    click_cell(5, 5)

    expect(page).to have_content('Humanity won')
  end

  it "allows browsing the history" do
    visit root_path
    click_cell(5, 5)

    click_on "view previous games"
    expect(page).to have_content('Finished games')

    click_on "Game ##{game_with_one_mine.id}: Humanity won"
    expect(page).to have_content("Game ##{game_with_one_mine.id} (finished)")
    expect(page).to have_content('Humanity won')
    expect(page).to have_content('1 1 1')
  end
end
