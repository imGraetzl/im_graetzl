module PaginationHelper

  def next_page_url
    url_for(params.permit!.merge(page: (params[:page] || 1).to_i + 1))
  end

end
