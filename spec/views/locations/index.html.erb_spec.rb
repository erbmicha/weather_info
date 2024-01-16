describe "locations/index.html.erb", type: :view do
  it "displays the search form" do
    render

    expect(rendered).to match(I18n.t("locations.form.address_label"))
  end
end
