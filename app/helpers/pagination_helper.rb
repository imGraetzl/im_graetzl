module PaginationHelper
  def view_more_link(resource, params: {}, style: '')
    content_for(:rel_next_prev, rel_next_prev_link_tags(resource))
    link_to_next_page resource, 'Mehr anzeigen',
      remote: true,
      data: { disable_with: 'lädt...' },
      params: params,
      class: 'link-load' + style
  end
end
