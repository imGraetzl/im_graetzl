ActiveAdmin.register Subscription do
  menu label: "Abos", priority: 3

  actions :all, except: [:destroy, :edit]

  scope :initialized, default: true
  scope :active
  scope :upcoming_invoice
  scope "Überfällig", :past_due
  scope "Auslaufend", :on_grace_period
  scope :canceled
  scope :all

  controller do
    before_action :set_default_order, only: :index

    def scoped_collection
      super.includes(:user, :subscription_plan, :coupon)
    end

    def set_default_order
      if params[:scope] == 'upcoming_invoice' && params[:order].blank?
        params[:order] = 'current_period_end_asc'
      elsif params[:scope] == 'auslaufend' && params[:order].blank?
        params[:order] = 'ends_at_asc'
      end
    end
  end

  filter :region_id, label: 'Region', as: :select, collection: proc { Region.all }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :user_id_eq, label: "User Suche", as: :string, input_html: {
    class: 'admin-autocomplete-component',
    placeholder: 'Name, Username oder E-Mail ...',
    data: { autocomplete_url: '/admin/autocomplete/users', target_input: 'q[user_id_eq]' }
  }
  filter :subscription_plan, include_blank: true, input_html: { class: 'admin-filter-select'}

  index { render 'index', context: self }

end
