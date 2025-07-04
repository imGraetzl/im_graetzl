ActiveAdmin.register CouponHistory do
  menu parent: 'Einstellungen'

  index { render 'index', context: self }

  scope :redeemed, default: true
  scope :valid
  scope :expired
  scope :all

  filter :user_id_eq, label: "User Suche", as: :string, input_html: {
    class: 'admin-autocomplete-component',
    placeholder: 'Name, Username oder E-Mail ...',
    data: { autocomplete_url: '/admin/autocomplete/users', target_input: 'q[user_id_eq]', scope: 'with_coupon_histories' }
  }
  filter :stripe_id
  filter :sent_at
  filter :redeemed_at
  filter :created_at

  permit_params :user_id, :coupon_id, :stripe_id, :sent_at, :redeemed_at

  controller do
    def scoped_collection
      super.includes(:user, :coupon)
    end
  end

end
