describe Weather::VisualCrossingApi do
  describe '.url' do
    it 'returns the url', :vcr do
      stub_const('Weather::VisualCrossingApi::API_KEY', '12345')

      expect(described_class.url(latitude: 12.345, longitude: 123.45)).to eq(
        "https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/12.345%2C123.45/" \
        "next7days?unitGroup=us" \
        "&elements=datetime%2Cname%2Caddress%2CresolvedAddress%2Clatitude%2Clongitude%2Ctempmax%2Ctempmin%2Ctemp%2C" \
        "feelslike%2Cdew%2Chumidity%2Cprecipprob%2Cpreciptype%2Cwindgust%2Cwindspeed%2Cwinddir%2Cpressure%2C" \
        "conditions%2Cdescription%2Cicon" \
        "&include=current%2Cdays" \
        "&key=12345" \
        "&contentType=json"
      )
    end

    it 'raises an error message if the units are invalid' do
      expect { described_class.url(latitude: 12.345, longitude: 123.45, units: 'invalid') }.to raise_error(
        ArgumentError, 'Invalid units'
      )
    end
  end
end
