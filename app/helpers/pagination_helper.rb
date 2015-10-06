module PaginationHelper
  def view_more_link(resource)
    link_to_next_page resource, 'Mehr',
      remote: true,
      data: { disable_with: "<i class='fa fa-spinner fa-spin'></i> lädt..." },
      class: 'btn-primary view-more'    
  end
end