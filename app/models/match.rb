class Match < ApplicationRecord
  has_many :games
  belongs_to :owner, class_name: "Account", foreign_key: "owner_id", optional: true

  scope :active, -> { where(finished: false) }
  scope :communal, -> { where(owner: nil) }

  def self.current
    self.communal.active.first
  end

  def communal?
    owner_id.nil?
  end

  def private?
    !communal?
  end

  def current_game!
    games.in_play.first || NewGame.create(**configuration, match: self)
  rescue ActiveRecord::RecordNotUnique
    # We will hit this if another thread started the game
    # in the same match, at the same time.
    retry
  end

  def wins
    games.win.count
  end

  def loses
    games.lose.count
  end

  private

  def configuration
    games.last&.configuration || {}
  end
end
