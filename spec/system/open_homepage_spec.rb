require 'rails_helper'

RSpec.describe "Opening the home page", type: :system do
  it "renders the home page without errors" do
    visit root_path
    expect(page).to have_content("Mines vs Humanity")
  end
end
