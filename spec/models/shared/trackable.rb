RSpec.shared_examples :a_trackable do

  describe 'associations' do
    let(:trackable) { create described_class }

    describe 'activities' do
      it 'has activities' do
        expect(trackable).to respond_to :activities
      end

      it 'destroys activities' do
        create_list :activity, 3, trackable: trackable
        expect{trackable.destroy}.to change{Activity.count}.from(3).to 0
      end
    end
  end

  describe '#create_activity' do
    let(:trackable) { create described_class }
    let(:owner) { create :user }
    let(:recipient) { create :user }

    it 'creates a new activity record' do
      expect{
        trackable.create_activity :key
      }.to change{Activity.count}.by 1
    end

    describe 'activity' do
      subject(:activity) { trackable.create_activity :key, owner: owner, recipient: recipient }

      it 'includes class_name in key' do
        class_name = described_class.name.underscore
        expect(activity.key).to eq "#{class_name}.key"
      end

      it 'associates trackable, owner and recipient' do
        expect(activity).to have_attributes(
          trackable: trackable,
          owner: owner,
          recipient: recipient
        )
      end
    end
  end
end
