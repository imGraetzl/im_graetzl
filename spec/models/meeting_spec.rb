require 'rails_helper'
require 'carrierwave/test/matchers'

RSpec.describe Meeting, type: :model do
  include CarrierWave::Test::Matchers
  
  # check factory
  it 'has a valid factory' do
    expect(build_stubbed(:meeting)).to be_valid
  end

  # validations
  describe 'validations' do
    it 'invalid without name' do
      expect(build(:meeting, name: nil)).not_to be_valid
    end

    it 'invalid with starts_at_date in past' do
      expect(build(:meeting, starts_at_date: 1.day.ago)).not_to be_valid
    end

    it 'invalid with ends_at_time before_starts_at_time' do
      expect(build(:meeting, starts_at_date: Date.today, starts_at_time: Time.now + 1.hour, ends_at_time: Time.now)).not_to be_valid
    end
  end


  describe '#cover_photo' do
    let(:meeting) { build_stubbed(:meeting) }

    context 'when file uploaded' do
      before do
        File.open(File.join(Rails.root, 'spec', 'support', 'cover_photo_test.png')) do |f|
          meeting.cover_photo = f
        end        
      end

      it 'has cover_photo' do
        expect(meeting.cover_photo.identifier).to eq('cover_photo_test.png')
      end

      it 'has retina dimension' do
        expect(meeting.cover_photo).to have_dimensions(1800, 1000)
      end

      it 'has small version' do
        expect(meeting.cover_photo.small).to have_dimensions(900, 500)
        expect(meeting.cover_photo_url(:small)).to include('small_cover_photo_test.png')
      end
    end

    context 'when no file uploaded' do

      it 'returns default avatar' do
        expect(meeting.cover_photo_url).to eq('cover_photo/default.jpg')
      end

      it 'returns small version' do
        expect(meeting.cover_photo_url(:small)).to include('small_default.jpg')
      end
    end
  end


  describe '#upcoming?' do
    let(:meeting) { build_stubbed(:meeting) }

    context 'without starts_at_date' do

      it 'has no starts_at_date' do
        expect(meeting.starts_at_date).to be_falsey
      end

      it 'returns true' do
        expect(meeting.upcoming?).to be_truthy
      end
    end

    context 'with starts_at_date in future' do
      before { meeting.starts_at_date = Date.tomorrow }
      
      it 'has starts_at_date' do
        expect(meeting.starts_at_date).to be_truthy
      end

      it 'returns true' do
        expect(meeting.upcoming?).to be_truthy
      end
    end

    context 'with starts_at_date in past' do
      before { meeting.starts_at_date = Date.yesterday }
      
      it 'has starts_at_date' do
        expect(meeting.starts_at_date).to be_truthy
      end

      it 'returns true' do
        expect(meeting.upcoming?).to be_falsey
      end
    end
  end
  

  describe '#past?' do
    let(:meeting) { build_stubbed(:meeting) }

    context 'without starts_at_date' do

      it 'has no starts_at_date' do
        expect(meeting.starts_at_date).to be_falsey
      end

      it 'returns true' do
        expect(meeting.past?).to be_falsey
      end
    end

    context 'with starts_at_date in future' do
      before { meeting.starts_at_date = Date.tomorrow }
      
      it 'has starts_at_date' do
        expect(meeting.starts_at_date).to be_truthy
      end

      it 'returns true' do
        expect(meeting.past?).to be_falsey
      end
    end

    context 'with starts_at_date in past' do
      before { meeting.starts_at_date = Date.yesterday }
      
      it 'has starts_at_date' do
        expect(meeting.starts_at_date).to be_truthy
      end

      it 'returns true' do
        expect(meeting.past?).to be_truthy
      end
    end
  end
end