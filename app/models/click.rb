class Click < ApplicationRecord
  include HasCoordinate

  belongs_to :game

  scope :ordered, -> { order(:id) }
end
