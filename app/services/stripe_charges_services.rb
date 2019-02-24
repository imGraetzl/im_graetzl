class StripeChargesServices
  DEFAULT_CURRENCY = 'eur'.freeze

  def initialize(params, user)
    @stripe_token = params[:stripeToken]
    @stripe_email = params[:stripeEmail]
    @amount = params[:amount].to_i * 100
    @user = user # current_user if logged in
  end

  def call
    create_charge(find_customer)
  end

  private

  attr_accessor :stripe_token, :stripe_email, :amount, :user

  def find_customer
  if user && user.stripe_customer_id
    retrieve_customer(user.stripe_customer_id)
  else
    create_customer
  end
  end

  def retrieve_customer(stripe_token)
    Stripe::Customer.retrieve(stripe_token)
  end

  def create_customer
    customer = Stripe::Customer.create(
      email: stripe_email,
      source: stripe_token
    )
    #save stripe_customer_id at user
    user.update(stripe_customer_id: customer.id) if user
    customer
  end

  def create_charge(customer)
    Stripe::Charge.create(
      customer: customer.id,
      amount: amount,
      currency: DEFAULT_CURRENCY
    )
  end

end
