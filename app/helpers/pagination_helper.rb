module PaginationHelper

  def next_page_url
    url_for(params.permit!.merge(page: (params[:page] || 1).to_i + 1))
  end

  def view_more_link(resource, params: {}, style: :'')
    link_to_next_page resource, 'Mehr anzeigen',
      remote: true,
      data: {
        disable_with: 'lädt...',
        behavior: 'paginate-link'
      },
      params: params,
      class: 'link-load' + ' -' + style.to_s
  end

  def view_more_of(resource, param)
    link_to_next_page resource, 'Mehr anzeigen',
      remote: true,
      data: {
        disable_with: 'lädt...',
        behavior: "paginate-#{param}"
      },
      param_name: param,
      class: 'link-load'
  end

  def view_more_scoped(resource, scope, style: :'')
    link_to_next_page resource, 'Mehr anzeigen',
      remote: true,
      data: {
        disable_with: 'lädt...',
        behavior: "paginate-#{scope}"
      },
      param_name: scope,
      params: { scope: scope },
      id: "link-load-#{scope}",
      class: 'link-load' + ' -' + style.to_s
  end
end
