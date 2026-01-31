class ContactListEntriesController < ApplicationController
  layout :set_layout
  rate_limit to: 25, within: 5.minutes, only: [:submit_sheboost]
  SHEBOOST_SLIDER_LIMIT = 2
  SHEBOOST_TIME_ZONE = 'Europe/Vienna'
  SHEBOOST_NOMINATION_END_AT = Time.find_zone(SHEBOOST_TIME_ZONE)
    .parse(ENV.fetch('SHEBOOST_NOMINATION_END_AT', '2026-02-01 00:00'))

  def sheboost
    @contact_list_entry = ContactListEntry.new
    @sheboost_entries_limit = SHEBOOST_SLIDER_LIMIT
    @sheboost_entries = sheboost_entries_scope('/sheboost').limit(SHEBOOST_SLIDER_LIMIT)
    @sheboost_nominations_closed = sheboost_nominations_closed?
  end

  def submit_sheboost
    if sheboost_nominations_closed?
      flash[:alert] = "Die Nominierungsphase ist beendet. Die sheBOOST Jury tagt nun.."
      redirect_to sheboost_path
      return
    end
    @contact_list_entry = ContactListEntry.new(contact_list_entries_params)
    @contact_list_entry.region_id = current_region.id if current_region
    @contact_list_entry.via_path = request.path
    if @contact_list_entry.save
      redirect_to params[:redirect_path]
      flash[:notice] = "Vielen Dank für deine Nominierung! Wenn du noch eine weitere inspirierende Frau kennst, nur zu..."
      MarketingMailer.contact_list_entry_sheboost(@contact_list_entry).deliver_later
      AdminMailer.new_contact_list_entry(@contact_list_entry).deliver_later
    else
      @sheboost_entries_limit = SHEBOOST_SLIDER_LIMIT
      @sheboost_entries = sheboost_entries_scope('/sheboost').limit(SHEBOOST_SLIDER_LIMIT)
      @sheboost_nominations_closed = sheboost_nominations_closed?
      render 'sheboost'
    end
  end

  def sheboost_entries
    page = params[:page].to_i
    page = 0 if page.negative?
    via_path = params[:via_path].presence || '/sheboost'
    @sheboost_entries = sheboost_entries_scope(via_path)
      .offset(page * SHEBOOST_SLIDER_LIMIT)
      .limit(SHEBOOST_SLIDER_LIMIT)
    render partial: 'contact_list_entries/sheboost_entry', collection: @sheboost_entries, as: :entry
  end

  private

  def contact_list_entries_params
    params.require(:contact_list_entry).permit(
      :region_id,
      :name,
      :email,
      :title,
      :url,
      :status,
      :message,
    )
  end

  def sheboost_entries_scope(via_path)
    ContactListEntry.where(via_path: via_path).order(created_at: :desc)
  end

  def sheboost_nominations_closed?
    Time.find_zone(SHEBOOST_TIME_ZONE).now >= SHEBOOST_NOMINATION_END_AT
  end

  def set_layout
    if current_region.nil?
      'platform'
    else
      'application'
    end
  end

end
