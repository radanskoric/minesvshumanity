require 'rails_helper'

RSpec.describe "Play the game", type: :system do
  fixtures :matches

  let!(:simple_game) do
    Game.create!(
      board: Board.create!(
        width: 10,
        height: 10,
        mines: [Mine.new(x: 2, y: 2), Mine.new(x: 7, y: 7)]
      ),
      match: matches(:public)
    )
  end

  it "allows creating clicks" do
    visit root_path
    expect(page).to have_no_content('1')

    click_cell(1, 1)
    expect(page).to have_content('1')
  end

  it "correctly detects when game has been lost" do
    visit root_path
    click_cell(2, 2)

    expect(page).to have_content('Humanity lost')
    expect(page).to have_content('Reloading to new game in')
  end

  it "correctly detects when game has been won" do
    visit root_path
    click_cell(5, 5)

    expect(page).to have_content('Humanity won')
    expect(page).to have_content('Reloading to new game in')
  end

  it "allows browsing the history" do
    visit root_path
    click_cell(5, 5)

    click_on "view previous games"
    expect(page).to have_content('Finished games')

    click_on "Game ##{simple_game.id}: Humanity won"
    expect(page).to have_content("Game ##{simple_game.id} (finished)")
    expect(page).to have_content('Humanity won')
    expect(page).to have_content('1 1 1')
  end

  it "allows multiple players to play together" do
    visit root_path
    expect(page).to have_no_content('1')

    Capybara.using_session "other user" do
      visit root_path
      click_cell(1, 1)
      expect(page).to have_content('1')
    end

    expect(page).to have_content('1')

    # Now first player finishes the game
    click_cell(5, 5)
    expect(page).to have_content('Humanity won')
    expect(page).to have_content('Reloading to new game in')

    # And other player sees that
    Capybara.using_session "other user" do
      expect(page).to have_content('Humanity won')
      expect(page).to have_content('Reloading to new game in')
    end
  end

  it "allows continuing to play automatically after game end" do
    visit root_path

    Capybara.using_session "other user" do
      visit root_path
      click_cell(2, 2) # mine
      expect(page).to have_content('Humanity lost')
    end

    expect(page).to have_content('Humanity lost')
    click_on "Refresh Now"
    expect(page).to have_no_content('Humanity lost')

    Capybara.using_session "other user" do
      click_on "Refresh Now"
      expect(page).to have_no_content('Humanity lost')
      mine = Match.current.current_game!.board.mines.first
      click_cell(mine.x, mine.y) # mine
      expect(page).to have_content('Humanity lost')
    end

    expect(page).to have_content('Humanity lost')
  end
end
