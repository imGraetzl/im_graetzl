class ContactListEntriesController < ApplicationController
  layout :set_layout

  def crowd2raum
    @contact_list_entry = ContactListEntry.new
  end

  def crowd2raum_create
    @contact_list_entry = ContactListEntry.new(contact_list_entries_params)
    @contact_list_entry.region_id = current_region.id if current_region
    @contact_list_entry.via_path = request.path
    if @contact_list_entry.save
      redirect_to params[:redirect_path]
      flash[:notice] = "Vielen Dank für deine Anmeldung! Wir melden uns in Kürze!"
      AdminMailer.new_contact_list_entry(@contact_list_entry).deliver_later
    else
      render 'crowd2raum'
    end
  end

  private

  def contact_list_entries_params
    params.require(:contact_list_entry).permit(
      :region_id,
      :name,
      :email,
    )
  end

  def set_layout
    if current_region.nil?
      'platform'
    else
      'application'
    end
  end

end
