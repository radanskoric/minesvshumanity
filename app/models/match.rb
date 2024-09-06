class Match < ApplicationRecord
  FIRST_PUBLIC_MATCH_ID = 1 # I know, magic constant, it will do for now.

  has_many :games
  belongs_to :owner, class_name: "Account", foreign_key: "owner_id", optional: true

  scope :active, -> { where(finished: false) }
  scope :finished, -> { where(finished: true) }
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

  def first_public?
    self.id == FIRST_PUBLIC_MATCH_ID
  end

  private

  def configuration
    games.last&.configuration || {}
  end
end
