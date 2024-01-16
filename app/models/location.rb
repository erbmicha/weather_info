class Location < ApplicationRecord
  # for geocoder gem
  geocoded_by :address
  after_validation :geocode, if: ->(obj) { obj.address.present? and obj.address_changed? }

  validates :address, presence: true
end
