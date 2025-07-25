ActiveAdmin.register SubscriptionInvoice do
  menu parent: 'Subscriptions'
  actions :all, except: [:new, :create, :destroy, :edit]

  scope :all, default: true
  scope :paid
  scope :unpaid
  scope :free
  scope :refunded
  scope :uncollectible

  filter :user_id_eq, label: "User Suche", as: :string, input_html: {
    class: 'admin-autocomplete-component',
    placeholder: 'Name, Username oder E-Mail ...',
    data: { autocomplete_url: '/admin/autocomplete/users', target_input: 'q[user_id_eq]' }
  }
  filter :amount
  filter :stripe_payment_intent_id
  filter :created_at

  index { render 'index', context: self }
  show { render 'show', context: self }

  controller do
    def apply_pagination(chain)
      chain = super unless formats.include?(:json) || formats.include?(:csv)
      chain
    end
    def apply_filtering(chain)
        super(chain).distinct
    end
  end

  csv do
    column :id
    column :created_at
    #column(:email) {|i| i.subscription.user.email if i.subscription.user }
    #column :amount
    column(:amount) { |i| number_to_currency(i.amount, precision: 2 ,unit: "") }
    column :status
    column(:status) { |i| i.subscription.status }
    column(:start) { |i| i.subscription.current_period_start }
    column(:end) { |i| i.subscription.current_period_end }
    column(:region_id) { |i| i.subscription.region_id }
  end

end
