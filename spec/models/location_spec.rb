describe Location do
  subject { Location.new(address: "Portland, OR") }

  it do
    expect { Location.new.save! }.to raise_error(
      ActiveRecord::RecordInvalid,
      "Validation failed: Address can't be blank"
    )
  end

  it "geocodes the address for a new Location" do
    VCR.use_cassette("portland") do
      subject.save!
    end

    expect(subject.latitude).to be_present
    expect(subject.longitude).to be_present
  end

  it "geocodes the address if the address has changed" do
    VCR.use_cassette("portland") do
      subject.save!
    end

    lat = subject.latitude
    lng = subject.longitude

    VCR.use_cassette("eugene") do
      subject.update!(address: "Eugene, OR")
    end

    expect(subject.latitude).not_to eq(lat)
    expect(subject.longitude).not_to eq(lng)
  end
end

