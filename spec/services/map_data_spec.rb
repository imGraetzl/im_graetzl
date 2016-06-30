require 'rails_helper'

RSpec.describe MapData do
  describe 'attributes' do
    context 'when initialized with singular items' do
      let(:graetzl) { build :graetzl }
      let(:district) { build :district }

      subject { described_class.new district: district, graetzl: graetzl }

      it 'has private attribute districts with district' do
        expect(subject.send :districts).to eq [district]
      end
      it 'has private attribute graetzls with graetzl' do
        expect(subject.send :graetzls).to eq [graetzl]
      end
    end
    context 'when initialized with collection items' do
      let(:graetzls) { build_list :graetzl, 3 }
      let(:districts) { build_list :district, 2 }

      subject { described_class.new districts: districts, graetzls: graetzls }

      it 'has private attribute districts with district' do
        expect(subject.send :districts).to eq districts
      end
      it 'has private attribute graetzls with graetzl' do
        expect(subject.send :graetzls).to eq graetzls
      end
    end
    context 'when initialized single collection' do
      let(:districts) { build_list :district, 2 }

      subject { described_class.new districts: districts }

      it 'has private attribute districts with districts' do
        expect(subject.send :districts).to eq districts
      end
      it 'has private attribute graetzls nil' do
        expect(subject.send :graetzls).to be_nil
      end
    end
  end

  describe '#call' do
    context 'for district and graetzls' do
      let(:district) { create :district }
      let(:graetzls) { create_list :graetzl, 3 }
      let(:service) {
        described_class.new district: district, graetzls: graetzls }

      subject { service.call }

      it 'returns json string' do
        expect(subject).to be_a String
      end
      it 'contains districts and graetzls collections' do
        hash = JSON.parse subject
        expect(hash.keys).to match_array ['districts', 'graetzls']
      end
      it 'contains feature collections for both attributes' do
        hash = JSON.parse subject
        expect(hash.values).to all(be_a Hash)
      end
      it 'contains feature collections for each item' do
        hash = JSON.parse subject
        attrs = ['type', 'features']
        expect(hash.values.map(&:keys)).to all(match_array attrs)
      end
    end
  end

  describe '.call' do
    let(:district) { create :district }
    let(:graetzls) { create_list :graetzl, 3 }

    subject { described_class.call district: district, graetzls: graetzls }

    it 'initializes new MapData and calls it' do
      expect(subject).to be_a String
      hash = JSON.parse subject
      expect(hash.keys).to match_array ['districts', 'graetzls']
    end
  end
end
