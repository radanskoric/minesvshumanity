class Mine < ApplicationRecord
  include HasCoordinate

  belongs_to :board
end
