class RedirectController < ApplicationController

  def wien
    if params[:wien_path].blank?
      redirect_to region_index_url
    elsif ['raumteiler/raumsuche', 'raumteiler/raum'].any?{|p| params[:wien_path].start_with?(p)}
      redirect_to normalized_path(params[:wien_path].delete_prefix('raumteiler'))
    elsif ['raumteiler', 'gruppen', 'locations', 'treffen', 'zuckerl'].any?{|p| params[:wien_path].start_with?(p)}
      redirect_to normalized_path("/region/" + params[:wien_path])
    elsif current_region.districts.any?{|d| params[:wien_path].start_with?(d.slug) }
      redirect_to normalized_path("/bezirk/#{params[:wien_path]}")  
    else
      redirect_to normalized_path("/" + params[:wien_path])
    end
  end

  def rooms
    if current_region
      redirect_to region_rooms_url
    else
      redirect_to root_url
    end
  end

  def energies
    if current_region
      redirect_to region_energies_url
    else
      redirect_to root_url
    end
  end

  private

  def normalized_path(path)
    "/" + path.to_s.sub(%r{^/+}, '')
  end

end
