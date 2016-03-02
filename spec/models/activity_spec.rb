require 'rails_helper'

RSpec.describe Activity, type: :model do

  it 'has a valid factory' do
    expect(build :activity).to be_valid
  end

  describe 'associations' do
    let(:activity) { build :activity }

    it 'has trackable' do
      expect(activity).to respond_to :trackable
    end

    it 'has owner' do
      expect(activity).to respond_to :owner
    end

    it 'has recipient' do
      expect(activity).to respond_to :recipient
    end
  end
end
