context.instance_eval do
  attributes_table do
    row :id
    row :location
    row :title
    row :description
    row :image do |z|
      z.image ? attachment_image_tag(z, :image, :fill, 400, 400) : nil
    end
    row :flyer
    row(:aasm_state){|z| status_tag(z.aasm_state)}
    row :paid_at
    row(:payment_reference){|z| z.payment_reference}
    row :initiative
    row :created_at
    row :updated_at
  end
end
