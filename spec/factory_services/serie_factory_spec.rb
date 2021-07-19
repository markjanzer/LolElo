# frozen_string_literal: true

RSpec.describe SerieFactory do
  describe "#call" do
    subject { SerieFactory.new(serie_data).call }
    let(:serie_data) {
      {
        "id" => 1, 
        "year" => 2019, 
        "begin_at" => "2019-01-26T22:00:00Z",
        "full_name" => "Spring 2019",
      }
    }

    context "without serie_data" do
      let(:serie_data) { nil }

      it "raises an error" do
        expect { subject }.to raise_error "serie_data is required"
      end
    end

    it "returns a serie with set attributes" do
      expect(subject).to have_attributes({
        panda_score_id: 1,
        year: 2019,
        begin_at: DateTime.parse("2019-01-26T22:00:00Z"),
        full_name: "Spring 2019"
      })
    end

    it "does not create the serie" do
      expect(subject).to_not be_persisted
    end
  end
end
