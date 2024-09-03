require 'rails_helper'

RSpec.describe Match, type: :model do
  fixtures :accounts

  describe ".current" do
    subject(:current) { described_class.current }

    before do
      Match.communal.destroy_all
      described_class.create(finished: true)
    end

    it "returns the match in play state if it exists" do
      active_match = Match.create
      expect(current).to eq active_match
    end

    it "ignores private matches" do
      Match.create(owner: accounts(:freddie))
      Match.create(owner: accounts(:brian))
      public_match = Match.create
      expect(current).to eq public_match
    end

    it "returns nil if it does not exist" do
      expect(current).to be_nil
    end
  end

  describe "#communal?" do
    it "returns true for games with no owner" do
      expect(Game.new(owner: nil)).to be_communal
    end

    it "returns false for games with an owner" do
      expect(Game.new(owner: accounts(:freddie))).not_to be_communal
    end
  end

  describe "#private?" do
    it "returns true for games with an owner" do
      expect(Game.new(owner: accounts(:freddie))).to be_private
    end

    it "returns false for games with no owner" do
      expect(Game.new(owner: nil)).not_to be_private
    end
  end
end
