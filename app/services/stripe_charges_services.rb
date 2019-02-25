class StripeChargesServices
  DEFAULT_CURRENCY = 'eur'.freeze

  def initialize(params, user)
    @stripe_token = params[:stripeToken]
    @stripe_email = params[:stripeEmail]
    @amount = params[:amount].to_i * 100
    @description = params[:stripeDescription]
    @user = user # current_user if logged in
  end

  def init_charge
    create_charge(find_customer)
  end

  private

  attr_accessor :stripe_token, :stripe_email, :amount, :user, :description

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
    if user
      customer = Stripe::Customer.create(
        email: stripe_email,
        source: stripe_token,
        description: user.full_name,
        metadata: {
          user_id: user.id,
          user_role: user.business? ? 'business' : ''
        }
      )
      user.update(stripe_customer_id: customer.id) #save stripe_customer_id at user
    else
      customer = Stripe::Customer.create(
        email: stripe_email,
        source: stripe_token
      )
    end
    customer
  end

  def create_charge(customer)
    charge = Stripe::Charge.create(
      customer: customer.id,
      amount: amount,
      description: description,
      currency: DEFAULT_CURRENCY
    )
    puts charge.id # Todo: save charge infos in DB
  end

end
