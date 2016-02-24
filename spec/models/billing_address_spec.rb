require 'rails_helper'

RSpec.describe BillingAddress, type: :model do
  it 'has a valid factory' do
    expect(build_stubbed :billing_address).to be_valid
  end

  describe 'validations' do
    it 'is invalid without location' do
      expect(build :billing_address, location: nil).not_to be_valid
    end

    it 'is invalid without first_name' do
      expect(build :billing_address, first_name: nil).not_to be_valid
    end

    it 'is invalid without last_name' do
      expect(build :billing_address, last_name: nil).not_to be_valid
    end
  end

  describe 'associations' do
    let(:billing_address) { build :billing_address }

    it 'has location' do
      expect(billing_address).to respond_to :location
    end
  end

  describe '#full_name' do
    let(:billing_address) { build :billing_address }

    describe 'set full_name' do
      it 'raises NoMethodError for nil value' do
        expect{
          billing_address.full_name = nil
        }.to raise_error NoMethodError
      end
      context 'with blank value' do
        it 'changes first_name to blank' do
          expect{
            billing_address.full_name = ''
          }.to change{billing_address.first_name}.to ''
        end

        it 'changes last_name to blank' do
          expect{
            billing_address.full_name = ''
          }.to change{billing_address.last_name}.to ''
        end
      end
      context 'with 1 value' do
        it 'changes first_name to blank' do
          expect{
            billing_address.full_name = 'Muster'
          }.to change{billing_address.first_name}.to ''
        end

        it 'changes last_name to value' do
          expect{
            billing_address.full_name = 'Muster'
          }.to change{billing_address.last_name}.to 'Muster'
        end
      end
      context 'with 2 values' do
        it 'changes first_name to first value' do
          expect{
            billing_address.full_name = 'Maxi Muster'
          }.to change{billing_address.first_name}.to 'Maxi'
        end

        it 'changes last_name to value' do
          expect{
            billing_address.full_name = 'Maxi Muster'
          }.to change{billing_address.last_name}.to 'Muster'
        end
      end
      context 'with > 2 values' do
        it 'changes first_name to first values' do
          expect{
            billing_address.full_name = 'Maxi Muster Lastname'
          }.to change{billing_address.first_name}.to 'Maxi Muster'
        end

        it 'changes last_name to last value' do
          expect{
            billing_address.full_name = 'Maxi Muster Lastname'
          }.to change{billing_address.last_name}.to 'Lastname'
        end
      end
    end

    describe 'get full_name' do
      before do
        billing_address.first_name = 'Maxi'
        billing_address.last_name = 'Muster'
      end

      it 'returns first_name last_name' do
        expect(billing_address.full_name).to eq 'Maxi Muster'
      end
    end
  end

  describe '#full_city' do
    let(:billing_address) { build :billing_address }

    describe 'set full_city' do
      it 'raises NoMethodError for nil value' do
        expect{
          billing_address.full_city = nil
        }.to raise_error NoMethodError
      end
      context 'with 1 value' do
        it 'changes zip to value' do
          expect{
            billing_address.full_city = '1070'
          }.to change{billing_address.zip}.to '1070'
        end

        it 'changes city to blank' do
          expect{
            billing_address.full_city = '1070'
          }.to change{billing_address.city}.to ''
        end
      end
      context 'with > 1 value' do
        it 'changes zip to first value' do
          expect{
            billing_address.full_city = '1070 Wien Something'
          }.to change{billing_address.zip}.to '1070'
        end

        it 'changes city to last values' do
          expect{
            billing_address.full_city = '1070 Wien Something'
          }.to change{billing_address.city}.to 'Wien Something'
        end
      end
    end
  end
end
