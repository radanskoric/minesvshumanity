class Click < ApplicationRecord
  include HasCoordinate

  belongs_to :game
end
