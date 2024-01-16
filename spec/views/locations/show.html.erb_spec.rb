describe "locations/show.html.erb" do
  let(:location) do
    VCR.use_cassette("portland") do
      Location.create!(address: "Portland, OR")
    end
  end
  let(:weather_json) { File.read(Rails.root.join("spec", "fixtures", "weather_api", "visual_crossing.json")) }
  let(:weather) { JSON.parse(weather_json) }

  it "displays the location's weather" do
    assign(:location, location)
    assign(:weather, weather)

    render

    expect(rendered).to match(I18n.t("locations.results.current_title", address: location.address))
    expect(rendered).to match(I18n.t("locations.results.current_temp", temp: weather["currentConditions"]["temp"]))
    expect(rendered).to match(
      I18n.t("locations.results.current_feels_like", temp: weather["currentConditions"]["feelslike"])
    )
    expect(rendered).to match(
      I18n.t("locations.results.current_humidity", humidity: weather["currentConditions"]["humidity"])
    )
    expect(rendered).to match(
      I18n.t("locations.results.current_chance_of_rain", chance_of_rain: weather["currentConditions"]["precipprob"])
    )
    expect(rendered).to match(
      I18n.t(
        "locations.results.current_wind",
        wind_direction: weather["currentConditions"]["winddir"],
        wind: weather["currentConditions"]["windspeed"]
      )
    )
    expect(rendered).to match(
      I18n.t("locations.results.current_gusts", gusts: weather["currentConditions"]["windgust"])
    )
  end
end
