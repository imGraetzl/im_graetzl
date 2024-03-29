module ToolsHelper

  def tool_categories_select_options
    ToolCategory.order(:position).map do |category|
      [category.name, category.id]
    end
  end

  def tool_insurance_values
    [1000, 2000, 3000, 4000, 5000].map do |value|
      ["Bis zu #{value} €", value]
    end
  end

  def tool_discount_values
    [5, 10, 15, 20, 25, 30, 40, 50].map do |value|
      ["#{value} %", value]
    end
  end

  def user_rating(user)
    return if user.rating.nil?
    html = content_tag(:div, class: 'user-rating') do
      content_tag(:span, '☆', class: 'fill') +
      content_tag(:span, '☆', class: user.rating > 1.5 ? 'fill' : nil) +
      content_tag(:span, '☆', class: user.rating > 2.5 ? 'fill' : nil) +
      content_tag(:span, '☆', class: user.rating > 3.5 ? 'fill' : nil) +
      content_tag(:span, '☆', class: user.rating > 4.5 ? 'fill' : nil)
    end
    html += content_tag(:small, "(#{user.ratings_count})", class: 'txt')
    html
  end

  def tool_rental_params
    params.permit(
      :tool_offer_id, :rent_from, :rent_to, :renter_company, :renter_name, :renter_address,
      :renter_zip, :renter_city,
    )
  end
end
