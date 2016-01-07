module PaginationHelper
  def view_more_link(resource, params: {}, style: :'')
    content_for(:rel_next_prev, rel_next_prev_link_tags(resource))
    link_to_next_page resource, 'Mehr anzeigen',
      remote: true,
      data: {
        disable_with: 'lädt...',
        behavior: 'paginate-link'
      },
      params: params,
      class: 'link-load' + ' -' + style.to_s
  end

  def view_more_scoped(resource, scope, style: :'')
    link_to_next_page resource, 'Mehr anzeigen',
      remote: true,
      data: { disable_with: 'lädt...' },
      param_name: scope,
      params: { scope: scope },
      id: "link-load-#{scope}",
      class: 'link-load' + ' -' + style.to_s
  end
end
