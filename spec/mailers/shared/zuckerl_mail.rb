RSpec.shared_examples :a_zuckerl_mail do
  describe '#deliver' do
    let!(:user) { create :user }
    let!(:location) { create :location, :approved }
    let!(:ownership) { create :location_ownership, user: user, location: location }
    let!(:zuckerl) { create :zuckerl, location: location }

    subject { described_class.new zuckerl }

    it 'calls mandrill api' do
      subject.deliver
      expect(WebMock).to have_requested :post, mandrill_url
    end
  end
end
