# frozen_string_literal: true

RSpec.describe SnapshotSeeder do
  describe "#call" do
    subject { SnapshotSeeder.new(serie).call }
    let(:serie) { create(:serie) }

    context "if the serie is not defined" do
      it "raises an error" do
        expect { subject }.to raise_error "serie not defined"
      end
    end

    it "raises an error if the serie does not exist"
  end
end