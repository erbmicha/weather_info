describe "Locations" do
  describe "GET /index" do
    it "returns http success" do
      get "/locations"

      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    it "returns http success", :vcr do
      post "/locations", params: { location: { address: "Portland, OR" } }

      expect(response).to have_http_status(:redirect)
    end
  end

  describe "GET /show/1", :vcr do
    let!(:location) { Location.create!(address: "Portland, OR") }

    it "returns http success" do
      get "/locations/1"

      expect(response).to have_http_status(:success)
    end
  end
end
