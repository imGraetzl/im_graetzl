ActiveAdmin.register RoomBooster do
  menu parent: 'Raumteiler'
  includes :room_offer, :user
  actions :all, except: [:new, :create, :destroy, :edit]

  scope :initialized, default: true
  scope :pending
  scope :active
  scope :expired
  scope :storno
  scope :incomplete
  scope :free
  scope :all

  index { render 'index', context: self }

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
    column :starts_at_date
    #column(:email) {|booster| booster.user.email if booster.user }
    column :status
    column :payment_status
    #column :amount
    column(:amount) { |i| number_to_currency(i.amount, precision: 2 ,unit: "") }
    column :region_id
  end

end
