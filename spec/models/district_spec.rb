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

  describe 'numberic' do
    context 'when single number district' do
      let(:district) { create(:district, zip: '1070') }

      it 'returns single digit' do
        expect(district.numeric).to eq '7'
      end
    end

    context 'when double number district' do
      let(:district) { create(:district, zip: '1160') }

      it 'returns single digit' do
        expect(district.numeric).to eq '16'
      end
    end
  end

  describe '#locations' do
    let(:district) { create(:district) }
    let(:graetzl_1) { create(:graetzl) }
    let(:graetzl_2) { create(:graetzl) }
    let(:other_graetzl) { create(:graetzl) }
    let(:location_1) { create(:location, graetzl: graetzl_1) }
    let(:location_2) { create(:location, graetzl: graetzl_1) }
    let(:location_3) { create(:location, graetzl: graetzl_2) }
    let(:location_4) { create(:location, graetzl: other_graetzl) }

    before do
      allow_any_instance_of(District).to receive(:graetzls).and_return([graetzl_1, graetzl_2])
    end

    subject(:locations) { district.locations }

    it 'returns locations from graetzls ordered by :created_at' do
      expect(locations).to eq [location_1, location_2, location_3]
    end

    it 'excludes locations from other graetzls' do
      expect(locations).not_to include(location_4)
    end
  end

  describe '#meetings' do
    let(:district) { create(:district) }
    let(:graetzl_1) { create(:graetzl) }
    let(:graetzl_2) { create(:graetzl) }
    let(:other_graetzl) { create(:graetzl) }
    let(:meeting_1) { create(:meeting, graetzl: graetzl_1) }
    let(:meeting_2) { create(:meeting, graetzl: graetzl_1) }
    let(:meeting_3) { create(:meeting, graetzl: graetzl_2) }
    let(:meeting_4) { create(:meeting, graetzl: other_graetzl) }

    before do
      allow_any_instance_of(District).to receive(:graetzls).and_return([graetzl_1, graetzl_2])
    end

    subject(:meetings) { district.meetings }

    it 'returns meetings from graetzls' do
      expect(meetings).to include(meeting_1, meeting_2, meeting_3)
    end

    it 'excludes meetings from other graetzls' do
      expect(meetings).not_to include(meeting_4)
    end
  end

  describe '#curators' do
    let(:district) { create(:district) }
    let(:graetzl_1) { create(:graetzl) }
    let(:graetzl_2) { create(:graetzl) }
    let(:other_graetzl) { create(:graetzl) }
    let(:curator_1) { create(:curator, graetzl: graetzl_1) }
    let(:curator_2) { create(:curator, graetzl: graetzl_1) }
    let(:curator_3) { create(:curator, graetzl: graetzl_2) }
    let(:curator_4) { create(:curator, graetzl: other_graetzl) }

    before do
      allow_any_instance_of(District).to receive(:graetzls).and_return([graetzl_1, graetzl_2])
    end

    subject(:curators) { district.curators }

    it 'returns curators from graetzls' do
      expect(curators).to include(curator_1, curator_2, curator_3)
    end

    it 'excludes curators from other graetzls' do
      expect(curators).not_to include(curator_4)
    end
  end
end
