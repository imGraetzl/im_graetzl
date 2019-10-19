context.instance_eval do
  attributes_table do
    row :id
    row :created_at
    row(:aasm_state){|z| status_tag(z.aasm_state)}
    row :all_districts
    row :visibility
    row(:payment_reference){|z| z.payment_reference}
    row :paid_at
    row :invoice_number
    row :location
    row :title
    row :description
    row :image do |z|
      z.image ? attachment_image_tag(z, :image, :fill, 400, 400) : nil
    end
    row :flyer
    row :initiative
    row :updated_at
  end
end
