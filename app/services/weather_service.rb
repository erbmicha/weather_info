class WeatherService
  class WeatherServiceError < StandardError; end

  SERVICES = %i[visual_crossing].freeze
  CACHE_EXPIRATION = 30.minutes

  class << self
    def call(latitude:, longitude:, service: :visual_crossing)
      new(latitude, longitude, service).call
    end
  end

  def initialize(latitude, longitude, service)
    @latitude = latitude
    @longitude = longitude
    @service = service

    validate
  end

  def call
    cached_response = Rails.cache.read("#{latitude}-#{longitude}-#{service}")
    return JSON.parse(cached_response) if cached_response.present?

    raise WeatherServiceError, "Location not found" if Rails.cache.read("#{latitude}-#{longitude}-#{service}-not-found")

    url = service_class.url(latitude: latitude, longitude: longitude)
    process_response(url)
  rescue ArgumentError, JSON::ParserError => e
    raise WeatherServiceError, e.message
  end

  private ######################################################################

  attr_reader :latitude, :longitude, :service

  private_class_method :new

  # save the lat/lon and service so we don't anger the API gods by asking for something they don't have
  def cache_location_not_found_response
    Rails.cache.write("#{latitude}-#{longitude}-#{service}-not-found", true)
  end

  def cache_response(data)
    Rails.cache.write("#{latitude}-#{longitude}-#{service}", data, expires_in: CACHE_EXPIRATION)
  end

  def process_request(url)
    uri = URI(url)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    Net::HTTP.get_response(uri)
  end

  def process_response(url)
    response = process_request(url)

    case response.code.to_i
    when 200
      cache_response(response.body)

      JSON.parse(response.body)
    when 400
      raise WeatherServiceError, "Bad request"
    when 401
      raise WeatherServiceError, "Unauthorized - check API key"
    when 404
      cache_location_not_found_response

      raise WeatherServiceError, "Location not found"
    when 429
      raise WeatherServiceError, "Too many requests"
    else
      raise WeatherServiceError, "Weather service error: #{response.code}"
    end
  end

  def service_class
    case service.to_s
    when "visual_crossing"
      Weather::VisualCrossingApi
    else
      raise ArgumentError, "Invalid service"
    end
  end

  def validate
    latitude_regex = /^-?\d{1,2}(?:\.\d{1,8})?$/
    longitude_regex = /^-?\d{1,3}(?:\.\d{1,8})?$/

    raise ArgumentError, "Invalid latitude" unless latitude.to_s.match?(latitude_regex)
    raise ArgumentError, "Latitude out of range" unless (-90..90).cover?(latitude)
    raise ArgumentError, "Invalid longitude" unless longitude.to_s.match?(longitude_regex)
    raise ArgumentError, "Longitude out of range" unless (-180..180).cover?(longitude)
  end
end
