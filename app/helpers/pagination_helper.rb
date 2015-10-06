module PaginationHelper
  def view_more_link(resource)
    link_to_next_page resource, 'Mehr anzeigen',
      remote: true,
      data: { disable_with: 'lädt...' },
      class: 'btn-primary view-more'    
  end
end