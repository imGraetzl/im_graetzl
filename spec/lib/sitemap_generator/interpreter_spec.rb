require 'rails_helper'

describe SitemapGenerator::Interpreter do
  describe '.run' do
    before do
      allow(SitemapGenerator::Sitemap).to receive(:ping_search_engines).and_return true
      allow(SitemapGenerator::Sitemap).to receive(:create).and_yield
    end

    context 'without data' do
      it 'does not raise error' do
        expect{described_class.run}.not_to raise_error
      end
    end

    context 'with district and graetzl data' do
      before do
        create_list(:district, 23)
        create_list(:graetzl, 120)
      end

      it 'does not raise error' do
        expect{described_class.run}.not_to raise_error
      end

      it 'does not raise error with meetings' do
        create_list(:meeting, 100, graetzl: Graetzl.first)
        expect{described_class.run}.not_to raise_error
      end

      it 'does not raise error with locations' do
        create_list(:location, 100, graetzl: Graetzl.first)
        expect{described_class.run}.not_to raise_error
      end
    end
  end
end
