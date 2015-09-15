require 'rails_helper'

RSpec.describe 'meetings/index', type: :view do

  # Shared examples
  shared_examples :display_action_button do

    it 'displays special box' do
      expect(rendered).to have_selector('div.ownMeetingBox')
    end
    
    it 'displays link to start meeting' do
      expect(rendered).to have_xpath("//a[@href='/#{graetzl.slug}/treffen/new']")
      expect(rendered).to have_button('Treffen anlegen')
    end
  end

  shared_examples :special_box_on_3rd do 
    it 'displays special box on 3rd position' do
      expect(rendered).to have_xpath('(//div[@class="meetingBox"])[2]/following-sibling::div[@class="ownMeetingBox"][1]')
    end
  end

  shared_examples :no_past_meetings do
    it 'does not display headline for past meetings' do
      expect(rendered).not_to have_selector('h1', text: "Vergangene Treffen im #{graetzl.name}")
    end
  end

  # Scenarios
  # Setup
  let(:graetzl) { create(:graetzl) }
  before do
    assign(:graetzl, graetzl)
  end

  context 'with 2 upcoming and past meetings' do
    let!(:m_today) { create(:meeting, graetzl: graetzl, starts_at_date: Date.today) }
    let!(:m_tomorrow) { create(:meeting, graetzl: graetzl, starts_at_date: Date.tomorrow) }
    let(:m_yesterday) { build(:meeting, graetzl: graetzl, starts_at_date: Date.yesterday) }

    before do
      m_yesterday.save(validate: false)
      assign(:upcoming_meetings, graetzl.meetings.upcoming)
      assign(:past_meetings, graetzl.meetings.past)
      render
    end

    include_examples :display_action_button

    include_examples :special_box_on_3rd

    it 'displays headline for upcoming meetings' do
      expect(rendered).to have_selector('h1', text: 'Komm doch dazu - aktuelleTreffen, Events & Veranstaltungen')
    end

    it 'displays upcoming meetings' do
      expect(rendered).to have_selector('div.meetingBox h3', text: m_today.name)
      expect(rendered).to have_selector('div.meetingBox h3', text: m_tomorrow.name)
    end

    it 'displays headline for past meetings' do
      expect(rendered).to have_selector('h1', text: "Vergangene Treffen im #{graetzl.name}")
    end

    it 'displays past meetings' do
      expect(rendered).to have_selector('div.meetingBox h3', text: m_yesterday.name)
    end
  end

  context 'when only upcoming meetings' do
    let!(:m_today) { create(:meeting, graetzl: graetzl, starts_at_date: Date.today) }

    before do
      5.times{ create(:meeting, graetzl: graetzl) }
      assign(:upcoming_meetings, graetzl.meetings.upcoming)
      assign(:past_meetings, graetzl.meetings.past)
      render
    end

    include_examples :display_action_button
   
    include_examples :special_box_on_3rd

    it 'displays headline for upcoming meetings' do
      expect(rendered).to have_selector('h1', text: 'Komm doch dazu - aktuelleTreffen, Events & Veranstaltungen')
    end

    it 'displays upcoming meetings' do
      expect(rendered).to have_selector('div.meetingBox h3', text: m_today.name)
      expect(rendered).to have_selector('div.meetingBox h3', count: 6)
    end

    include_examples :no_past_meetings
  end

  context 'when no meetings' do
    before do
      assign(:upcoming_meetings, graetzl.meetings.upcoming)
      assign(:past_meetings, graetzl.meetings.past)
      render
    end

    include_examples :display_action_button

    it 'displays headline for upcoming meetings' do
      expect(rendered).to have_selector('h1', text: 'Komm doch dazu - aktuelleTreffen, Events & Veranstaltungen')
    end

    it 'displays no meetings' do
      expect(rendered).not_to have_selector('div.meetingBox h3')
    end

    include_examples :no_past_meetings
  end
end