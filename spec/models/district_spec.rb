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

  describe '#long_name' do
    let(:named_district) { build(:district, name: 'district', zip: '1234') }

    it 'concats name and zip' do
      expect(named_district.long_name).to eq('district-1234')
    end
  end

  describe 'numeric' do
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

    it 'excludes locations from other graetzls' do
      expect(locations).not_to include(location_4)
    end
  end

  describe '#meetings' do
    let(:graetzl_1) { create(:graetzl) }
    let(:graetzl_2) { create(:graetzl) }
    let(:other_graetzl) { create(:graetzl) }
    let(:district) { create :district, graetzls: [graetzl_1, graetzl_2] }
    let(:meeting_1) { create(:meeting, graetzl: graetzl_1) }
    let(:meeting_2) { create(:meeting, graetzl: graetzl_1) }
    let(:meeting_3) { create(:meeting, graetzl: graetzl_2) }
    let(:meeting_4) { create(:meeting, graetzl: other_graetzl) }

    subject(:meetings) { district.meetings }

    it 'returns meetings from graetzls' do
      expect(meetings).to include(meeting_1, meeting_2, meeting_3)
    end

    it 'excludes meetings from other graetzls' do
      expect(meetings).not_to include(meeting_4)
    end
  end

  describe '#zuckerls' do
    let(:graetzl_1) { create :graetzl }
    let(:graetzl_2) { create :graetzl }
    let(:other_graetzl) { create :graetzl }
    let(:district) { create :district, graetzls: [graetzl_1, graetzl_2] }

    subject(:zuckerls) { district.zuckerls }

    before { allow_any_instance_of(Zuckerl).to receive(:send_booking_confirmation) }

    it 'returns live zuckerl from graetzl locations' do
      zuckerl_records = create_list(:zuckerl, 5,
        location: create(:location, graetzl: [graetzl_1, graetzl_2].sample),
        aasm_state: 'live')
      expect(zuckerls).to match_array zuckerl_records
    end

    it 'does not include zuckerls from other graetzls' do
      zuckerl_record = create(:zuckerl,
        location: create(:location, graetzl: other_graetzl),
        aasm_state: 'live')
      expect(zuckerls).not_to include(zuckerl_record)
    end
  end
end
