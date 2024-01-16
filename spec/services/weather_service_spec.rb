describe WeatherService do
  let(:latitude) { 45.5202471 }
  let(:longitude) { -122.674194 }
  let(:service) { :visual_crossing }
  let(:service_url) { "https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline" }
  let(:response_body) { File.read(Rails.root.join("spec", "fixtures", "weather_api", "visual_crossing.json")) }

  subject { described_class.call(latitude: latitude, longitude: longitude) }

  before do
    allow(Weather::VisualCrossingApi).to receive(:url).and_return(service_url)
  end

  describe '.call' do
    context 'when there is no cached response' do
      before do
        allow(Rails.cache).to receive(:write)
        allow(Net::HTTP).to receive(:get_response).and_return(
          instance_double(Net::HTTPOK, code: '200', body: response_body)
        )
        allow(JSON).to receive(:parse)
        subject
      end

      it 'makes an API call' do
        expect(Net::HTTP).to have_received(:get_response)
      end

      it 'caches the response' do
        expect(Rails.cache).to have_received(:write).with(
          "#{latitude}-#{longitude}-#{service}",
          response_body,
          expires_in: described_class::CACHE_EXPIRATION
        )
      end

      it 'returns the weather data' do
        expect(JSON).to have_received(:parse).with(response_body)
      end
    end

    context 'when there is a cached response' do
      it 'returns the weather data' do
        allow(JSON).to receive(:parse)
        allow(Rails.cache).to receive(:read).with("#{latitude}-#{longitude}-#{service}").and_return(response_body)

        subject

        expect(JSON).to have_received(:parse).with(response_body)
      end
    end

    context 'when the location was not found previously' do
      before do
        allow(Rails.cache).to receive(:read).with("#{latitude}-#{longitude}-#{service}").and_return(nil)
        allow(Rails.cache).to receive(:read).with("#{latitude}-#{longitude}-#{service}-not-found").and_return(true)
        allow(Net::HTTP).to receive(:get_response)
      end

      it 'raises LocationNotFoundError and does not make an API call' do
        expect { subject }.to raise_error(WeatherService::WeatherServiceError, "Location not found")
        expect(Net::HTTP).not_to have_received(:get_response)
      end
    end

    context 'when the location is not found by the API' do
      before do
        allow(Net::HTTP).to receive(:get_response).and_return(instance_double(Net::HTTPNotFound, code: '404'))
        allow(Rails.cache).to receive(:write)
      end

      it 'caches the location not found response and raises an error' do
        expect { subject }.to raise_error(WeatherService::WeatherServiceError, "Location not found")
        expect(Rails.cache).to have_received(:write).with("#{latitude}-#{longitude}-#{service}-not-found", true)
      end
    end

    context 'when there is a bad request' do
      it 'raises BadRequest' do
        allow(Net::HTTP).to receive(:get_response).and_return(instance_double(Net::HTTPBadRequest, code: '400'))

        expect { subject }.to raise_error(WeatherService::WeatherServiceError, "Bad request")
      end
    end

    context 'when unauthorized' do
      it 'raises Unauthorized' do
        allow(Net::HTTP).to receive(:get_response).and_return(instance_double(Net::HTTPUnauthorized, code: '401'))

        expect { subject }.to raise_error(WeatherService::WeatherServiceError, "Unauthorized - check API key")
      end
    end

    context 'when too many requests' do
      it 'raises TooManyRequestsError' do
        allow(Net::HTTP).to receive(:get_response).and_return(instance_double(Net::HTTPTooManyRequests, code: '429'))

        expect { subject }.to raise_error(WeatherService::WeatherServiceError, "Too many requests")
      end
    end

    context 'when there is an unidentified API error' do
      it 'raises WeatherService::WeatherServiceError' do
        allow(Net::HTTP).to receive(:get_response).and_return(instance_double(Net::HTTPConflict, code: '409'))

        expect { subject }.to raise_error(WeatherService::WeatherServiceError, "Weather service error: 409")
      end
    end

    context 'when there is a JSON parsing error' do
      let(:bad_json_response) { instance_double(Net::HTTPOK, code: '200', body: 'bad json') }

      it 'raises WeatherService::WeatherServiceError' do
        allow(Net::HTTP).to receive(:get_response).and_return(bad_json_response)

        expect { subject }.to raise_error(WeatherService::WeatherServiceError, "unexpected token at 'bad json'")
      end
    end

    context 'when there is an argument error' do
      it 'raises WeatherService::WeatherServiceError if service_class is not in the list' do
        expect { described_class.call(latitude: 0.0, longitude: 0.0, service: :acme) }.to raise_error(
          WeatherService::WeatherServiceError, "Invalid service"
        )
      end

      it 'raises WeatherService::WeatherServiceError if latitude is invalid' do
        expect { described_class.call(latitude: 'foo', longitude: 0.0) }.to raise_error(
          ArgumentError, "Invalid latitude"
        )
      end

      it 'raises WeatherService::WeatherServiceError if latitude is out of range' do
        expect { described_class.call(latitude: 91.0, longitude: 0.0) }.to raise_error(
          ArgumentError, "Latitude out of range"
        )
      end

      it 'raises WeatherService::WeatherServiceError if longitude is invalid' do
        expect { described_class.call(latitude: 0.0, longitude: 'foo') }.to raise_error(
          ArgumentError, "Invalid longitude"
        )
      end

      it 'raises WeatherService::WeatherServiceError if longitude is out of range' do
        expect { described_class.call(latitude: 0.0, longitude: 200.0) }.to raise_error(
          ArgumentError, "Longitude out of range"
        )
      end
    end
  end
end
