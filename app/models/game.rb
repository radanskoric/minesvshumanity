class Game < ApplicationRecord
  belongs_to :board
  has_many :clicks, dependent: :delete_all
  belongs_to :owner, class_name: "Account", foreign_key: "owner_id", optional: true
  belongs_to :match, optional: true

  enum status: %i[play win lose]

  scope :finished, -> { where(status: Minesweeper::Game::END_STATUSES) }
  scope :in_play, -> { where(status: :play) }
  scope :reverse_by_creation, -> { order(id: :desc) }

  def finished?
    Minesweeper::Game::END_STATUSES.include?(status.to_sym)
  end

  def communal?
    owner_id.nil?
  end

  def private?
    !communal?
  end

  def to_game_object
    Minesweeper::Game.new(board.to_game_object).tap do |game|
      # We always go to the database to grabe the latest clicks because this way we handle
      # concurrent multiplayer clicks. This way we are guaranteed to always see a correct seqeuence
      # of clicks up to a specific click. We might see stale state but we are guaranteed to see
      # and accurate past state. The database internal locks take care of ensuring this.
      clicks.ordered.pluck(:x, :y, :mark_as_mine).each do |(x, y, mark_as_mine)|
        coord = Minesweeper::Coordinate.new(x, y)
        if mark_as_mine
          game.mark(coord)
        else
          game.reveal(coord)
        end
      end
    end
  end

  def click!(x:, y:, mark_as_mine: false)
    clicks.create!(x:, y:, mark_as_mine:)
    to_game_object.tap do |new_game_object|
      update!(status: new_game_object.status)
    end
  end

  # @param owner [Account] the account to replay the game for as a new private game.
  def replay_for(owner)
    Game.create!(board:, owner:, fair_start:).tap do |new_game|
      if fair_start
        first_click = clicks.ordered.first
        new_game.click!(x: first_click.x, y: first_click.y)
      end
    end
  end

  def configuration
    {
      width: board.width,
      height: board.height,
      mines: board.mines.count,
      fair_start: fair_start
    }
  end
end
