require 'rails_helper'

describe Disaster do
  context 'scoping' do

    let!(:active_disaster1) {create(:disaster, :is_active)}
    let!(:active_disaster2) {create(:disaster, :is_active)}

    let!(:inactive_disaster) {create(:disaster, :is_not_active)}


    it 'by active should only return active disasters' do
      expect(Disaster.active.length).to eq(2)
    end

    it 'by inactive should only return inactive disasters' do
      expect(Disaster.inactive.length).to eq(1)
    end
  end
end