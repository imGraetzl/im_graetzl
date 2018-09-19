class SearchController < ApplicationController
  def index
    if params[:q]
      searchterm = params[:q]
      page = params[:page] || 1

      if params[:label]
        if params[:label] == 'all'
          label = ''
        else
          label = " + ' more:' + " + params[:label]
        end
      else
        label = ''
      end

      @results = GoogleCustomSearchApi.search(searchterm + label, page: page, as_sitesearch: params[:as_sitesearch])

    end
  end
end
