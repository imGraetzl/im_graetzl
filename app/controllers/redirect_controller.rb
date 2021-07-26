class RedirectController < ApplicationController

  def wien
    if params[:wien_path].blank?
      redirect_to region_index_url
    elsif params[:wien_path].start_with?('raumteiler')
      # wien/raumteiler/raumsuche, wien/raumteiler/raum/, wien/raumteiler/open-calls
      redirect_to params[:wien_path].delete_prefix('raumteiler')
    elsif current_region.districts.any?{|d| params[:wien_path].start_with?(d.slug) }
      redirect_to "/bezirk/#{params[:wien_path]}"
    else
      redirect_to params[:wien_path]
    end
  end

end