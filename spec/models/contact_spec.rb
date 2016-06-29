require 'rails_helper'

RSpec.describe Contact, type: :model do
  it 'has a valid factory' do
    expect(build :contact).to be_valid
  end

  describe 'validations' do
    it 'is invalid with invalid url as website' do
      expect(build :contact, website: 'google.de').not_to be_valid
    end
  end
end
