class AddStripePaymentToZuckerls < ActiveRecord::Migration[6.1]
  def change

    add_column :zuckerls, :payment_status, :string
    add_column :zuckerls, :payment_method, :string
    add_column :zuckerls, :payment_card_last4, :string
    add_column :zuckerls, :stripe_payment_method_id, :string
    add_column :zuckerls, :stripe_payment_intent_id, :string

    rename_column :zuckerls, :paid_at, :debited_at
    remove_column :zuckerls, :flyer

  end
end
