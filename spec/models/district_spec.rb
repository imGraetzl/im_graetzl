require 'rails_helper'

RSpec.describe District, type: :model do

  describe 'default scope' do
    let(:third_district) { create(:district, zip: '1030') }
    let(:first_district) { create(:district, zip: '1010') }
    let(:second_district) { create(:district, zip: '1020') }

    it 'retrieves ordered by zip' do
      expect(District.all).to eq [first_district, second_district, third_district]
    end
  end

  describe '#graetzls' do
    let(:district) { create(:district) }

    let!(:g_covering) { create(:graetzl) }
    let!(:g_within) { create(:graetzl,
      area: 'POLYGON ((1.0 1.0, 1.0 2.0, 2.0 2.0, 2.0 1.0, 1.0 1.0))') }
    let!(:g_overlapping) { create(:graetzl,
      area: 'POLYGON ((1.0 1.0, 1.0 15.0, 15.0 15.0, 15.0 1.0, 1.0 1.0))') }
    let!(:g_outside) { create(:graetzl,
      area: 'POLYGON ((15.0 15.0, 15.0 20.0, 20.0 20.0, 15.0 15.0))') }

    subject(:graetzls) { district.graetzls }

    it 'returns covering/overlapping areas' do
      expect(graetzls.size).to eq 3
    end

    it 'includes areas fully covering' do
      expect(graetzls).to include g_covering
    end

    it 'includes areas within' do
      expect(graetzls).to include g_within
    end

    it 'includes areas overlapping' do
      expect(graetzls).to include g_overlapping
    end

    it 'excludes areas outside' do
      expect(graetzls).not_to include g_outside
    end

  end

  describe '#long_name' do
    let(:named_district) { build(:district, name: 'district', zip: '1234') }

    it 'concats name and zip' do
      expect(named_district.long_name).to eq('district-1234')
    end
  end
end
