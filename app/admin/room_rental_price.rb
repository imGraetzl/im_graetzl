ActiveAdmin.register RoomRentalPrice do
  menu parent: 'Raumteiler'
  includes :room_offer
  actions :all, except: [:new, :create, :destroy, :edit]

  config.sort_order = 'room_offer_id_desc'

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
    column :room_offer_id
    #column(:status) {|price| price&.room_offer&.status }
    #column :room_offer
    #column(:email) {|price| price&.room_offer&.email }
    column :price_per_hour
    column :minimum_rental_hours
    column :eight_hour_discount
  end

end
