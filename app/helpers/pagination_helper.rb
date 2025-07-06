module PaginationHelper
  def next_page_url(collection)
    return nil unless collection.respond_to?(:next_page) && collection.next_page.present?
    params_hash = request.query_parameters.merge(page: collection.next_page)
    url_for(params_hash)
  end
end
