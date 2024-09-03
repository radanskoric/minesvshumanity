class NewGame
  include ActiveModel::Model
  include ActiveModel::Attributes

  # The default game settings are the same as Expert level in Minesweeper
  # on Windows 3.1 to Windows XP , see https://www.minesweeper.info/wiki/Windows_Minesweeper
  attribute :width, :integer, default: 30
  attribute :height, :integer, default: 16
  attribute :mines, :integer, default: 99
  # A flag on whether to start with automatic first reveal on an empty cell
  attribute :fair_start, :boolean, default: false
  # Setting this means the game is private.
  attribute :owner
  # Setting this means the game is part of a match, like on the home page.
  attribute :match

  validates :width, :height, presence: true, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 50 }
  validates :mines, presence: true, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 500 }
  validates :fair_start, inclusion: { in: [true, false] }

  class << self
    def model_name
      ActiveModel::Name.new(self, nil, "Game")
    end

    def create(...)
      new(...).save
    end
  end

  def to_h
    attributes.symbolize_keys
  end

  def save
    return false unless valid?

    game_board, first_reveal = Minesweeper::Board.generate_random(width, height, mines, fair_start:)
    board = Board.create!(
      width: game_board.width,
      height: game_board.height,
      mines: game_board.mines.map { |mine| Mine.new(x: mine.x, y: mine.y) }
    )
    Game.create!(board: board, fair_start:, owner:, match:).tap do |game|
      game.click!(x: first_reveal.x, y: first_reveal.y) if fair_start
    end
  end
end
