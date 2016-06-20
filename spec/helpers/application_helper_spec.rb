require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#form_errors_for' do
    let(:target) { build :meeting }

    it 'does nothing when target valid' do
      expect(helper.form_errors_for target).to be_nil
    end

    context 'when target with errors' do
      before { target.errors.add(:name) }

      it 'renders error partial with model name' do
        expect(helper).to receive(:render).with('errors', target: target, name: 'Treffen')
        helper.form_errors_for target
      end
      it 'renders error partial with custom name' do
        expect(helper).to receive(:render).with('errors', target: target, name: 'Custom Name')
        helper.form_errors_for target, 'Custom Name'
      end
    end
  end
end
