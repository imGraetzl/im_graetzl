require 'rails_helper'

RSpec.describe 'meetings/index', type: :view do

  # Shared examples
  shared_examples :display_action_button do
    it 'displays headline' do
      expect(rendered).to have_selector('h2', text: "Kommende Treffen im #{graetzl.name}")
    end

    it 'displays special box' do
      expect(rendered).to have_selector('div.specialBox')
    end
    
    it 'displays link to start meeting' do
      expect(rendered).to have_xpath("//a[@href='/#{graetzl.slug}/treffen/new']")
      expect(rendered).to have_button('Treffen anlegen')
    end
  end

  shared_examples :no_past_meetings do

    it 'does not display headline for past meetings' do
      expect(rendered).not_to have_selector('h2', text: "Vergangene Treffen im #{graetzl.name}")
    end

    it 'does not display past meetings' do
      expect(rendered).not_to have_selector('div.meetingBox h3', text: m_yesterday.name)
    end
  end

  # setup data
  let(:graetzl) { create(:graetzl) }
  let(:m_today) { create(:meeting, graetzl: graetzl, starts_at_date: Date.today) }
  let(:m_tomorrow) { create(:meeting, graetzl: graetzl, starts_at_date: Date.tomorrow) }
  let(:m_yesterday) { build(:meeting, graetzl: graetzl, starts_at_date: Date.yesterday) }

  before do
    m_yesterday.save(validate: false)
    allow(m_today).to receive(:initiator) { create(:user) }
    allow(m_tomorrow).to receive(:initiator) { create(:user) }
    allow(m_yesterday).to receive(:initiator) { create(:user) }
    assign(:graetzl, graetzl)
  end

  # scenarios
  context 'with meetings' do
    before do
      assign(:upcoming_meetings, [m_today, m_tomorrow])
      assign(:past_meetings, [m_yesterday])
      render
    end

    it_behaves_like :display_action_button

    it 'displays upcoming meetings' do
      expect(rendered).to have_selector('div.meetingBox h3', text: m_today.name)
      expect(rendered).to have_selector('div.meetingBox h3', text: m_tomorrow.name)
    end

    it 'displays headline for past meetings' do
      expect(rendered).to have_selector('h2', text: "Vergangene Treffen im #{graetzl.name}")
    end

    it 'displays past meetings' do
      expect(rendered).to have_selector('div.meetingBox h3', text: m_yesterday.name)
    end
  end

  context 'with only upcoming meetings' do
    before do
      assign(:upcoming_meetings, [m_today, m_tomorrow])
      assign(:past_meetings, nil)
      render
    end

    it_behaves_like :display_action_button

    it 'displays upcoming meetings' do
      expect(rendered).to have_selector('div.meetingBox h3', text: m_today.name)
      expect(rendered).to have_selector('div.meetingBox h3', text: m_tomorrow.name)
    end

    it_behaves_like :no_past_meetings
  end

  context 'without meetings' do
    before do
      assign(:upcoming_meetings, nil)
      assign(:past_meetings, nil)
      render
    end

    it_behaves_like :display_action_button

    it 'does not display upcoming meetings' do
      expect(rendered).not_to have_selector('div.meetingBox h3', text: m_today.name)
      expect(rendered).not_to have_selector('div.meetingBox h3', text: m_tomorrow.name)
    end

    it_behaves_like :no_past_meetings
  end
end