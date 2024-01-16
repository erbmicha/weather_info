module Geocoders
  module GeocodeGem
    extend ActiveSupport::Concern

    included do
      geocoded_by :address

      after_validation :geocode, if: :address_changed?
    end
  end
end
