module Weather
  class VisualCrossingApi
    API_KEY = ENV.fetch("VISUAL_CROSSING_API_KEY", Rails.application.credentials.visual_crossing_api_key)
    UNITS = %w(us metric uk).freeze

    class << self
      def url(latitude:, longitude:, units: 'us')
        new(latitude, longitude, units).url
      end
    end

    def initialize(latitude, longitude, units)
      raise "VISUAL_CROSSING_API_KEY not set" unless API_KEY.present?

      @latitude = latitude
      @longitude = longitude
      @units = units

      validate
    end

    def url
      url = "https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/"
      url << "#{latitude}%2C#{longitude}/next7days"
      url << "?unitGroup=us"
      url << "&elements=datetime%2Cname%2Caddress%2CresolvedAddress%2Clatitude%2Clongitude%2Ctempmax"
      url << "%2Ctempmin%2Ctemp%2Cfeelslike%2Cdew%2Chumidity%2Cprecipprob%2Cpreciptype%2Cwindgust%2Cwindspeed"
      url << "%2Cwinddir%2Cpressure%2Cconditions%2Cdescription%2Cicon"
      url << "&include=current%2Cdays"
      url << "&key=#{API_KEY}"
      url << "&contentType=json"
    end

    private ######################################################################

    attr_reader :latitude, :longitude, :units

    private_class_method :new

    def validate
      raise ArgumentError, 'Invalid units' unless UNITS.include?(units)
    end
  end
end
