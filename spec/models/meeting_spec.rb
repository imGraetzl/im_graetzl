require 'rails_helper'

RSpec.describe Meeting, type: :model do

  it 'has a valid factory' do
    expect(build_stubbed(:meeting)).to be_valid
  end

  describe 'validations' do
    it 'invalid without name' do
      expect(build(:meeting, name: nil)).not_to be_valid
    end

    it 'invalid without graetzl' do
      expect(build(:meeting, graetzl: nil)).not_to be_valid
    end

    it 'invalid when created with starts_at_date in past' do
      expect{
        create(:meeting, starts_at_date: 1.day.ago)
        }.to raise_error(ActiveRecord::RecordInvalid)
      expect(build(:meeting, starts_at_date: 1.day.ago)).not_to be_valid
    end

    it 'not invalid when updated with starts_at_date in past' do
      meeting = create(:meeting)
      expect{
        meeting.update(starts_at_date: 1.day.ago)
        }.not_to raise_error
    end

    it 'invalid with ends_at_time before_starts_at_time' do
      expect(build(:meeting, starts_at_date: Date.today, starts_at_time: Time.now + 1.hour, ends_at_time: Time.now)).not_to be_valid
    end
  end

  describe 'macros' do
    let(:meeting) { create(:meeting) }

    it 'has cover_photo with content_type' do
      expect(meeting).to respond_to(:cover_photo)
      expect(meeting).to respond_to(:cover_photo_content_type)
    end

    it 'has friendly_id' do
      expect(meeting).to respond_to(:friendly_id)
    end

    it 'has state (default :basic)' do
      expect(meeting).to respond_to(:state)
      expect(meeting.basic?).to be_truthy
    end
  end

  describe 'associations' do
    let(:meeting) { create(:meeting) }

    it 'has graetzl' do
      expect(meeting).to respond_to(:graetzl)
    end

    it 'has location' do
      expect(meeting).to respond_to(:location)
    end

    it 'has address' do
      expect(meeting).to respond_to(:address)
    end

    it 'destroys address when destroy' do
      create(:address, addressable: meeting)
      expect{meeting.destroy}.to change(Address, :count).by(-1)
    end

    it 'has going_tos' do
      expect(meeting).to respond_to(:going_tos)
    end

    it 'destroys going_tos when destroy' do
      create_list(:going_to, 3, meeting: meeting)
      expect{meeting.destroy}.to change(GoingTo, :count).by(-3)
    end

    it 'has users' do
      expect(meeting).to respond_to(:users)
    end

    it 'has comments' do
      expect(meeting).to respond_to(:comments)
    end

    it 'has categories' do
      expect(meeting).to respond_to(:categories)
    end

    it 'destroys comments when destroy' do
      create_list(:comment, 3, commentable: meeting)
      expect{meeting.destroy}.to change(Comment, :count).by(-3)
    end
  end

  describe 'scopes' do
    describe '.paginate_with_padding' do
      before { create_list(:meeting, 30) }

      context 'with page = 1' do
        subject(:meetings) { Meeting.paginate_with_padding 1 }

        it 'returns first 8 meetings' do
          expect(meetings).to eq Meeting.first(8)
        end
      end

      context 'with page = 2' do
        subject(:meetings) { Meeting.paginate_with_padding 2 }

        it 'returns first 9 with offset 8' do
          expect(meetings).to eq Meeting.offset(8).limit(9)
        end
      end
    end

    describe '.upcoming' do
      let!(:m_today) { create(:meeting, starts_at_date: Date.today) }
      let!(:m_tomorrow) { create(:meeting, starts_at_date: Date.tomorrow) }
      let!(:m_after_tomorrow) { create(:meeting, starts_at_date: Date.tomorrow+1) }
      let!(:m_nil) { create(:meeting, starts_at_date: nil) }
      let!(:m_yesterday) { create(:meeting_skip_validate, starts_at_date: Date.yesterday) }

      subject(:meetings) { Meeting.upcoming }

      it 'retrieves nearest first, nil last' do
        expect(meetings.to_a).to eq [m_today, m_tomorrow, m_after_tomorrow, m_nil]
      end

      it 'excludes past' do
        expect(meetings).not_to include(m_yesterday)
      end
    end

    describe '.past' do
      let!(:m_today) { create(:meeting, starts_at_date: Date.today) }
      let!(:m_nil) { create(:meeting, starts_at_date: nil) }
      let!(:m_yesterday) { create(:meeting_skip_validate, starts_at_date: Date.yesterday) }
      let!(:m_1_before_yesterday) { create(:meeting_skip_validate, starts_at_date: Date.yesterday-1) }
      let!(:m_2_before_yesterday) { create(:meeting_skip_validate, starts_at_date: Date.yesterday-2) }

      subject(:meetings) { Meeting.past }

      it 'retrieves past nearest first' do
        expect(meetings.to_a).to eq [m_yesterday, m_1_before_yesterday, m_2_before_yesterday]
      end

      it 'excludes nil and upcoming' do
        expect(meetings).not_to include(m_today)
        expect(meetings).not_to include(m_nil)
      end
    end

    describe '.initiated' do
      let(:initiated_meetings) { create_list(:meeting, 5) }
      let(:attended_meetings) { create_list(:meeting, 5) }
      before do
        initiated_meetings.each {|m| create(:going_to, meeting: m, role: GoingTo::roles[:initiator])}
        attended_meetings.each {|m| create(:going_to, meeting: m, role: GoingTo::roles[:attendee])}
      end

      subject(:meetings) { Meeting.initiated }

      it 'returns meetings with initiator going_tos' do
        expect(meetings.to_a).to match_array(initiated_meetings)
      end
    end

    describe '.attended' do
      let(:initiated_meetings) { create_list(:meeting, 5) }
      let(:attended_meetings) { create_list(:meeting, 5) }
      before do
        initiated_meetings.each {|m| create(:going_to, meeting: m, role: GoingTo::roles[:initiator])}
        attended_meetings.each {|m| create(:going_to, meeting: m, role: GoingTo::roles[:attendee])}
      end

      subject(:meetings) { Meeting.attended }

      it 'returns meetings with attendee going_tos' do
        expect(meetings.to_a).to match_array(attended_meetings)
      end
    end
  end

  describe 'callbacks' do
    let(:meeting) { create(:meeting) }

    describe '#before_destroy' do
      before do
        3.times do
          activity = create(:activity, trackable: meeting)
          create_list(:notification, 3, activity: activity)
        end
      end

      it 'destroys associated activity and notifications' do
        expect(PublicActivity::Activity.count).to eq 3
        expect(Notification.count).to eq 9

        meeting.destroy

        expect(Notification.count).to eq 0
        expect(PublicActivity::Activity.count).to eq 0
      end
    end
  end

  # describe '#initator' do
  #   let(:meeting) { create(:meeting) }
  #   let(:initiator) { create(:user) }

  #   context 'when present' do
  #     before { create(:going_to, meeting: meeting, user: initiator, role: GoingTo.roles[:initiator]) }

  #     it 'returns user' do
  #       expect(meeting.initiator).to eq initiator
  #     end
  #   end

  #   context 'when multiple present' do
  #     before do
  #       create(:going_to, meeting: meeting, role: GoingTo.role[:initiator])
  #       create(:going_to, meeting: meeting, user: initiator, role: GoingTo.roles[:initiator])
  #     end

  #     it 'returns last user' do
  #       expect(meeting.initiator).to eq initiator
  #     end
  #   end

  #   context 'when not present' do
  #     before do
  #       create(:going_to, meeting: meeting)
  #     end

  #     it 'returns nil' do
  #       expect(meeting.initiator).to be_nil
  #     end
  #   end
  # end
end
