require 'rails_helper'

RSpec.describe "Play a private game", type: :system do
  fixtures :matches, :accounts

  def login_with(email:, password:)
    fill_in "E-mail", with: email
    fill_in "Password", with: password
    within "main" do
      click_on "Login"
    end
  end

  def create_a_private_game!
    expect(page).to have_content("Create a new private game")
    fill_in "Width", with: "10"
    fill_in "Height", with: "10"
    fill_in "Mines", with: "10"
    click_on "Start My Private Game"
    expect(page).to have_content("Mines left: 10")
  end

  def lose_the_game!(game)
    mine = game.board.mines.first
    click_cell(mine.x, mine.y)
  end

  it "allows users to create private games after registering" do
    visit "/games/new"

    click_on "Create a New Account"
    fill_in "E-mail", with: "tester@example.com"
    fill_in "Password", with: "lozinka!"
    fill_in "Confirm Password", with: "lozinka!"
    click_on "Create Account"

    create_a_private_game!

    account = Account.find_by(email: "tester@example.com")
    expect(account.games.count).to eq(1)
    game = account.games.first
    expect(game.status).to eq("play")

    expect(page).to have_content("Game ##{game.id}")
    lose_the_game!(game)
    expect(page).to have_content("You lost.")
  end

  it "allows creating a private game after logging in with existing user" do
    owner = accounts(:freddie)
    visit "/games/new"
    login_with(email: owner.email, password: "password")

    create_a_private_game!

    game = owner.games.first
    expect(page).to have_content("Game ##{game.id}")
    lose_the_game!(game)
    expect(page).to have_content("You lost.")
    # No point in reloading a single private game
    expect(page).to have_no_content('Reloading to new game in')
  end

  it "shows errors if game is invalid" do
    owner = accounts(:freddie)
    visit "/games/new"
    login_with(email: owner.email, password: "password")

    expect(page).to have_content("Create a new private game")
    fill_in "Width", with: "1000"
    click_on "Start My Private Game"

    expect(page).to have_content("Width must be less than or equal to 50")
  end

  it "allows to replay a communal game privately, after it's finished" do
    Game.create!(board: Board.create!( width: 10, height: 10, mines: [Mine.new(x: 2, y: 2)]), match: matches(:public))
    visit "/login"
    login_with(email: accounts(:freddie).email, password: "password")

    visit "/"
    expect(page).not_to have_content("Replay this game")

    click_cell(5, 5)
    expect(page).to have_content("Humanity won!")
    expect(page).to have_content("Refresh Now")

    click_on "Replay This Game"
    expect(page).not_to have_content("Refresh Now")
    click_cell(5, 5)
    expect(page).to have_content("You won!")
  end

  context "with an existing private games" do
    let!(:private_game) do
      Game.create!(
        board: Board.create!(
          width: 10,
          height: 10,
          mines: [Mine.new(x: 2, y: 2)],
        ),
        owner: owner
      )
    end
    let(:owner) { accounts(:freddie) }

    context "when logged in as owner" do
      before do
        visit "/login"
        login_with(email: owner.email, password: "password")
        expect(page).to have_content("You have been logged in")
      end

      it "allows browsing existing private games" do
        visit "/games/my"

        expect(page).to have_content("My Games")
        expect(page).to have_content("Game ##{private_game.id}: In progress")

        click_on "Game ##{private_game.id}"

        expect(page).to have_content("Mines left: 1")
        click_cell(4, 4)
        expect(page).to have_content("You won!")
      end

      it "allows replaying it after its finished" do
        visit "/games/my"
        click_on "Game ##{private_game.id}"

        expect(page).to have_content("Mines left: 1")
        click_cell(2, 2)
        expect(page).to have_content("You lost.")

        click_on "Replay This Game"
        expect(page).to have_content("Mines left: 1")
        click_cell(4, 4)
        expect(page).to have_content("You won!")
      end
    end
  end
end
