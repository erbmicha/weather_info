describe "weather search" do
  before do
    driven_by(:rack_test)
  end

  scenario "displays the search form" do
    visit root_path

    expect(page).to have_content(I18n.t("locations.form.address_label"))
  end

  scenario "displays the results" do
    VCR.use_cassette("portland_weather") do
      visit root_path
      fill_in I18n.t("locations.form.address_label"), with: "Portland, OR"
      click_on I18n.t("locations.form.submit")
    end

    expect(page).to have_content(I18n.t("locations.results.current_title", address: "PORTLAND, OR"))
    expect(page).to have_content(I18n.t("locations.results.current_temp", temp: 24.9))
    expect(page).to have_content(
      I18n.t("locations.results.current_feels_like", temp: 15.3)
    )
    expect(page).to have_content(
      I18n.t("locations.results.current_humidity", humidity: 45.6)
    )
    expect(page).to have_content(
      I18n.t("locations.results.current_chance_of_rain", chance_of_rain: 0.0)
    )
    expect(page).to have_content(
      I18n.t(
        "locations.results.current_wind",
        wind_direction: 116.0,
        wind: 9.3
      )
    )
    expect(page).to have_content(
      I18n.t("locations.results.current_gusts", gusts: 18.9)
    )
  end
end
