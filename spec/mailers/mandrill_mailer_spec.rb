require 'rails_helper'
include Stubs::MandrillApi

RSpec.describe MandrillMailer do
  before { stub_mandrill_api! }

  let(:mandrill_url) {
    'https://mandrillapp.com/api/1.0/messages/send-template.json' }

  describe 'attributes' do
    context 'when initialized with template and message' do
      subject { described_class.new template: 'template', message: {} }

      it 'has private attribute @template' do
        expect(subject.send :template).to eq 'template'
      end
      it 'has private attribute @message' do
        expect(subject.send :message).to be_a Hash
      end
    end
    context 'when initialized without parameters' do
      subject { described_class.new }

      it 'has private attribute @template nil' do
        expect(subject.send :template).to be_nil
      end
      it 'has private attribute @message nil' do
        expect(subject.send :message).to be_nil
      end
    end
  end
  describe '#deliver' do
    context 'when template and message set' do
      subject { described_class.new template: 'template', message: {} }

      it 'calls mandrill api' do
        subject.deliver
        expect(WebMock).to have_requested :post, mandrill_url
      end
    end
    context 'when template missing' do
      subject { described_class.new message: {} }

      it 'does not call mandrill api' do
        subject.deliver
        expect(WebMock).not_to have_requested :post, mandrill_url
      end
    end
    context 'when message missing' do
      subject { described_class.new template: 'template-slug' }

      it 'does not call mandrill api' do
        subject.deliver
        expect(WebMock).not_to have_requested :post, mandrill_url
      end
    end
    context 'when message and template missing' do
      subject { described_class.new }

      it 'does not call mandrill api' do
        subject.deliver
        expect(WebMock).not_to have_requested :post, mandrill_url
      end
    end
  end

  describe '.deliver' do
    it 'initializes new Mailer and calls mandrill api' do
      described_class.deliver template: 'template-slug', message: {}
      expect(WebMock).to have_requested :post, mandrill_url
    end
  end
end
