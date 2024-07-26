class Click < ApplicationRecord
  include HasCoordinate

  belongs_to :game, touch: true

  scope :ordered, -> { order(:id) }
end
