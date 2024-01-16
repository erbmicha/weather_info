describe LocationsHelper do
  describe "#usa_date" do
    it "returns the date in USA format for a string" do
      expect(helper.usa_date("2019-01-01")).to eq("01/01/2019")
    end

    it "returns the date in USA format for a Date object" do
      expect(helper.usa_date(Date.parse("2019-01-01"))).to eq("01/01/2019")
    end
  end
end
