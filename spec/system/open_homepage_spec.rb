require 'rails_helper'

RSpec.describe "Opening the home page", type: :system do
  fixtures :matches

  it "renders the home page without errors" do
    visit root_path
    expect(page).to have_content("Mines vs Humanity")
  end

  context "when there are no public matches" do
    before { Match.communal.destroy_all }

    it "renders an empty state message" do
      visit root_path
      expect(page).to have_content("No public match currently in progress")
    end
  end
end
