require 'rails_helper'

RSpec.describe User, type: :model do
  
  it 'has a valid factory' do
    expect(build_stubbed(:user)).to be_valid
  end

  describe 'validations' do
    it 'invalid without username' do
      expect(build(:user, username: nil)).not_to be_valid
    end

    it 'invalid with dublicate username' do
      first_user = create(:user)
      expect(build(:user, username: first_user.username)).not_to be_valid
    end

    it 'invalid without first_name' do
      expect(build(:user, first_name: nil)).not_to be_valid
    end

    it 'invalid without last_name' do
      expect(build(:user, last_name: nil)).not_to be_valid
    end

    it 'invalid without graetzl' do
      expect(build(:user, graetzl: nil)).not_to be_valid
    end
  end

  describe 'attributes' do
    let(:user) { build_stubbed(:user) }

    describe 'role' do

      it 'has role' do
        expect(user).to respond_to(:role)
      end

      context 'when admin' do
        before { user.role = :admin }

        it 'responds #admin? true' do
          expect(user.admin?).to eq(true)
        end

        it 'responds #business? false' do
          expect(user.business?).to eq(false)
        end
      end

      context 'when business' do
        before { user.role = :business }

        it 'responds #business? true' do
          expect(user.business?).to eq(true)
        end

        it 'responds #admin? false' do
          expect(user.admin?).to eq(false)
        end
      end
    end
  end

  describe 'associations' do
    let(:user) { create(:user) }

    it 'has address' do
      expect(user).to respond_to(:address)
    end

    it 'has graetzl' do
      expect(user).to respond_to(:graetzl)
    end

    it 'has meetings' do
      expect(user).to respond_to(:meetings)
    end

    it 'has posts' do
      expect(user).to respond_to(:posts)
    end

    it 'has locations' do
      expect(user).to respond_to(:locations)
    end

    it 'has comments' do
      expect(user).to respond_to(:comments)
    end

    describe 'avatar' do

      it 'has avatar' do
        expect(user).to respond_to(:avatar)
      end

      it 'has avatar_content_type' do
        expect(user).to respond_to(:avatar_content_type)
      end
    end

    describe 'destroy associated records' do
      before { user.create_address(attributes_for(:address)) }

      it 'has address' do
        expect(user.address).not_to be_nil
      end

      it 'destroys address with user' do
        address = user.address
        user.destroy
        expect(Address.find_by_id(address.id)).to be_nil
      end
    end
  end

  # describe '#go_to' do
  #   let(:user) { create(:user) }
  #   let(:meeting) { create(:meeting) }

  #   context 'when attendee' do
  #     it 'creates new going_to with default role' do
  #       expect {
  #         user.go_to(meeting)
  #       }.to change(GoingTo, :count).by(1)
  #     expect(user.going_tos.last.attendee?).to be true
  #     end

  #     it 'adds going_to to user' do
  #       expect {
  #         user.go_to(meeting)
  #       }.to change(user.going_tos, :count).by(1)
  #     end

  #     it 'add meeting to user' do
  #       user.go_to(meeting)
  #       expect(user.meetings.last).to eq(meeting)
  #     end
  #   end

  #   context 'when initator' do      
  #     it 'creates going_to with role initator' do
  #       expect {
  #       user.go_to(meeting, GoingTo.roles[:initiator])
  #     }.to change(GoingTo, :count).by(1)
  #     expect(user.going_tos.last.initiator?).to be true
  #     end
  #   end
  # end

  # describe '#initiated?(meeting)' do
  #   let(:user) { create(:user) }
  #   let(:meeting) { create(:meeting) }

  #   context 'when initiator' do
  #     before do
  #       create(:going_to, user: user, meeting: meeting, role: GoingTo.roles[:initiator])
  #     end

  #     it 'returns true' do
  #       expect(user.initiated?(meeting)).to be_truthy
  #     end
  #   end

  #   context 'when attendee' do
  #     before do
  #       create(:going_to, user: user, meeting: meeting, role: GoingTo.roles[:attendee])
  #     end

  #     it 'returns false' do
  #       expect(user.initiated?(meeting)).to be_falsey
  #     end
  #   end

  #   context 'when not going' do
  #     it 'returns false' do
  #       expect(user.initiated?(meeting)).to be_falsey
  #     end
  #   end
  # end

  # describe '#going_to?(meeting)' do
  #   let(:user) { create(:user) }
  #   let(:meeting) { create(:meeting) }

  #   context 'when initiator' do
  #     before do
  #       create(:going_to, user: user, meeting: meeting, role: GoingTo::ROLES[:initiator])
  #     end

  #     it 'returns true' do
  #       expect(user.going_to?(meeting)).to be_truthy
  #     end
  #   end

  #   context 'when attendee' do
  #     before do
  #       create(:going_to, user: user, meeting: meeting, role: GoingTo::ROLES[:attendee])
  #     end

  #     it 'returns true' do
  #       expect(user.going_to?(meeting)).to be_truthy
  #     end
  #   end

  #   context 'when not going' do
  #     it 'returns false' do
  #       expect(user.going_to?(meeting)).to be_falsey
  #     end
  #   end
  # end

  describe "mail notifications" do
    let(:user) { create(:user, :graetzl => create(:graetzl)) }
    before do
      Notification::TYPES.keys.each do |type|
        bitmask = Notification::TYPES[type][:bitmask]
        create(:notification, user: user, bitmask: bitmask)
      end
    end

    describe "enabling" do
      let(:type) { :new_meeting_in_graetzl }

      it "can be enabled for a specific type" do
        expect(user.enabled_mail_notification?(type, :daily)).to be_falsey  
        user.enable_mail_notification(type, :daily)
        expect(user.enabled_mail_notification?(type, :daily)).to be_truthy
        expect(user.enabled_mail_notification?(type, :weekly)).to be_falsey  
        user.enable_mail_notification(type, :weekly)
        expect(user.enabled_mail_notification?(type, :weekly)).to be_truthy
        expect(user.enabled_mail_notification?(type, :immediate)).to be_falsey  
        user.enable_mail_notification(type, :immediate)
        expect(user.enabled_mail_notification?(type, :immediate)).to be_truthy
      end

      it "can only be set to either immediate, daily, or weekly" do
        expect(user.enabled_mail_notification?(type, :daily)).to be_falsey  
        user.enable_mail_notification(type, :daily)
        expect(user.enabled_mail_notification?(type, :daily)).to be_truthy
        user.enable_mail_notification(type, :weekly)
        expect(user.enabled_mail_notification?(type, :weekly)).to be_truthy
        expect(user.enabled_mail_notification?(type, :daily)).to be_falsey  
      end 
    end
  end

  describe "website_notifications" do
    let(:user) { create(:user, :graetzl => create(:graetzl)) }
    before do
      Notification::TYPES.keys.each do |type|
        bitmask = Notification::TYPES[type][:bitmask]
        create(:notification, user: user, bitmask: bitmask)
      end
    end

    describe "enabling" do
      it "can be enabled for a specific type" do
        type = :new_meeting_in_graetzl
        expect(user.enabled_website_notification?(type)).to be_falsey  
        user.enable_website_notification(type)
        expect(user.enabled_website_notification?(type)).to be_truthy
      end

      it "returns only enabled notifications" do
        expect(user.new_website_notifications_count).to eq(0)
        user.enable_website_notification(:new_meeting_in_graetzl)
        expect(user.new_website_notifications_count).to eq(1)
        user.enable_website_notification(:new_post_in_graetzl)
        expect(user.new_website_notifications_count).to eq(2)
        user.enable_website_notification(:another_attendee)
        user.toggle_website_notification(:new_meeting_in_graetzl)
        expect(user.new_website_notifications_count).to eq(2)
        user.toggle_website_notification(:another_attendee)
        expect(user.new_website_notifications_count).to eq(1)
      end
    end

    it "can be toggled for a specific type" do
      type = :new_meeting_in_graetzl
      expect(user.enabled_website_notification?(type)).to be_falsey  
      user.toggle_website_notification(type)
      expect(user.enabled_website_notification?(type)).to be_truthy
      user.toggle_website_notification(type)
      expect(user.enabled_website_notification?(type)).to be_falsey  
    end
  end
end
