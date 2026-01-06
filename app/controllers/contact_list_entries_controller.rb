class ContactListEntriesController < ApplicationController
  layout :set_layout
  rate_limit to: 25, within: 5.minutes, only: [:submit_sheboost]
  SHEBOOST_SLIDER_LIMIT = 2

  def sheboost
    @contact_list_entry = ContactListEntry.new
    @sheboost_entries_limit = SHEBOOST_SLIDER_LIMIT
    @sheboost_entries = sheboost_entries_scope('/sheboost').limit(SHEBOOST_SLIDER_LIMIT)
  end

  def submit_sheboost
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
    ContactListEntry.enabled.where(via_path: via_path).order(created_at: :desc)
  end

  def set_layout
    if current_region.nil?
      'platform'
    else
      'application'
    end
  end

end
