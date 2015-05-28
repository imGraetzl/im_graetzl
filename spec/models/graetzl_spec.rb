require 'rails_helper'

RSpec.describe Graetzl, type: :model do

  it 'has a valid factory' do
    expect(build(:graetzl)).to be_valid
  end

  # instance methods
  describe '#short_name' do
    let(:aspern) { build(:aspern) }
    it 'returns first part of name' do
      expect(aspern.short_name).to eql('Aspern')
    end
  end


  describe '#next_meetings' do
    let(:graetzl) { create(:graetzl) }

    context 'when no meetings' do

      it 'returns empty' do
        expect(graetzl.next_meetings).to be_empty
      end

      it 'returns empty array' do
        expect(graetzl.next_meetings).to eq([])
      end
    end

    context 'when meetings without date' do
      before do
        3.times { create(:meeting, graetzl: graetzl) }
        graetzl.save
      end

      it 'has meetings associated' do
        expect(graetzl.meetings.count).to eq(3)
      end

      it 'returns empty array' do
        expect(graetzl.next_meetings).to eq([])
      end
    end    

    context 'when meetings with date' do
      let!(:first_meeting) { create(:meeting, graetzl: graetzl, starts_at_date: Date.today + 1.day) }
      let!(:second_meeting) { create(:meeting, graetzl: graetzl, starts_at_date: Date.today + 2.days) }
      let!(:last_meeting) { create(:meeting, graetzl: graetzl, starts_at_date: Date.today + 3.days) }
      let(:past_meeting) { build(:meeting, graetzl: graetzl, starts_at_date: Date.yesterday) }

      before do
        past_meeting.save(validate: false)
      end

      it 'has meetings associated' do
        expect(graetzl.meetings.count).to eq(4)
      end

      it 'returns 2 meetings' do
        expect(graetzl.next_meetings.count).to eq(2)
      end

      it 'returns most recent' do
        expect(graetzl.next_meetings[0]).to eq(first_meeting)
        expect(graetzl.next_meetings[1]).to eq(second_meeting)
        expect(graetzl.next_meetings).not_to include(last_meeting)
      end

      it 'excludes past' do
        expect(graetzl.next_meetings).not_to include(past_meeting)
      end
    end
  end
end
