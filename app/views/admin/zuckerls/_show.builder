context.instance_eval do
  attributes_table do
    row :id
    row :created_at
    row(:aasm_state){|z| status_tag(z.aasm_state)}
    row :all_districts
    row :visibility
    row(:payment_reference){|z| z.payment_reference}
    row :invoice_number
    row :paid_at
    if zuckerl.invoice_number.present?
      row(:zuckerl_invoice) { |z| link_to "PDF Rechnung", z.zuckerl_invoice.presigned_url(:get) }
    end
    row :user do
      link_to zuckerl.location.user.username, admin_user_path(zuckerl.location.user)
    end
    row :location
    row :title
    row :description
    row :link
    row :image do |z|
      z.image && image_tag(z.image_url(:thumb))
    end
    row :flyer
    row :updated_at
  end
end
