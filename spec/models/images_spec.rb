require 'rails_helper'

RSpec.describe Image, type: :model do

  it 'has a valid factory' do
    expect(build_stubbed(:image)).to be_valid
  end

  describe 'associations' do
    let(:image) { create(:image) }

    it 'has file_content_type' do
      expect(image).to respond_to(:file_content_type)
    end
  end
end