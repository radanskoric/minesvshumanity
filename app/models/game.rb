class Game < ApplicationRecord
  belongs_to :board
  belongs_to :owner, class_name: "Account", foreign_key: "owner_id", optional: true
  has_many :clicks, dependent: :delete_all

  enum status: %i[play win lose]

  scope :finished, -> { where(status: Minesweeper::Game::END_STATUSES) }
  scope :in_play, -> { where(status: :play) }
  scope :reverse_by_creation, -> { order(id: :desc) }
  scope :communal, -> { where(owner: nil) }

  def self.current
    self.communal.in_play.first
  end

  # @param width [Integer]
  # @param height [Integer]
  # @param mines [Integer]
  # @param fair_start [Boolean] Whether to start with automatic first reveal
  # @param owner [Account] setting this means the game is private.
  def self.start_new(width, height, mines, fair_start: false, owner: nil)
    game_board, first_reveal = Minesweeper::Board.generate_random(width, height, mines, fair_start:)
    board = Board.create!(
      width: game_board.width,
      height: game_board.height,
      mines: game_board.mines.map { |mine| Mine.new(x: mine.x, y: mine.y) }
    )
    self.create!(board: board, fair_start:, owner:).tap do |game|
      game.click!(x: first_reveal.x, y: first_reveal.y) if fair_start
    end
  end

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
end
