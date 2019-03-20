class StripeChargesServices
  DEFAULT_CURRENCY = 'eur'.freeze
  DEFAULT_TAX = 20
  DEFAULT_TAX_COMMA = 1.2
  STRIPE_DASHBOARD = 'https://dashboard.stripe.com'

  def initialize(params, user)
    @user = user ? user : User.find_by_email(params[:stripeEmail])    # current_user if logged in
    @stripe_token = params[:stripeToken]
    @stripe_email = params[:stripeEmail]
    @amount = params[:amount].to_i * 100
    @amount_netto = (@amount / DEFAULT_TAX_COMMA).round
    @description = params[:stripeDescription]
    @message = params[:message]
    @plan = params[:stripePlan]
    @billing_cycle_anchor = DateTime.parse(params[:stripeBillingCycleAnchor]).to_i if params[:stripeBillingCycleAnchor].present?
    @trial_end = DateTime.parse(params[:stripeTrialEnd]).to_i if params[:stripeTrialEnd].present?
    @cancel_at_period_end = params[:stripeCancelAtPeriodEnd] if params[:stripeCancelAtPeriodEnd].present?
  end

  def init_charge
    create_charge(find_customer)
  end

  def init_invoice
    create_invoice_item(find_customer)
    create_invoice(@customer)
  end

  def init_subscription
    create_subscription(find_customer)
  end

  private

  attr_accessor :user,
                :stripe_token,
                :stripe_email,
                :amount,
                :amount_netto,
                :description,
                :message,
                :plan,
                :billing_cycle_anchor,
                :trial_end,
                :cancel_at_period_end

  def find_customer
  if user && user.stripe_customer_id
    retrieve_customer(user.stripe_customer_id)
  else
    create_customer
  end
  end

  def retrieve_customer(stripe_token)
    @customer = Stripe::Customer.retrieve(stripe_token)
    @customer
  end

  def create_customer
    if user
      @customer = Stripe::Customer.create(
        email: stripe_email,
        source: stripe_token,
        description: user.full_name,
        metadata: {
          user_id: user.id,
          user_role: user.business? ? 'business' : ''
        }
      )
      user.update(stripe_customer_id: @customer.id) #save stripe_customer_id at user
    else
      @customer = Stripe::Customer.create(
        email: stripe_email,
        source: stripe_token
      )
    end
    @customer
  end

  def create_charge(customer)
    charge = Stripe::Charge.create(
      customer: customer.id,
      currency: DEFAULT_CURRENCY,
      amount: amount,
      description: description
    )
    puts charge # Todo: save charge infos in DB
  end

  def create_invoice_item(customer)
    invoice_item = Stripe::InvoiceItem.create({
        customer: customer.id,
        currency: DEFAULT_CURRENCY,
        amount: amount_netto,
        description: description
    })
    #puts invoice_item # Todo: save charge infos in DB
  end

  def create_invoice(customer)
    invoice = Stripe::Invoice.create(
      customer: customer.id,
      tax_percent: DEFAULT_TAX,
      auto_advance: true
    )
    puts invoice # Todo: save charge infos in DB
    send_payment_confirmation("#{STRIPE_DASHBOARD}/invoices/#{invoice.id}")
  end

  def create_subscription(customer)
    subscription = Stripe::Subscription.create(
      customer: customer.id,
      tax_percent: DEFAULT_TAX,
      billing_cycle_anchor: billing_cycle_anchor,
      trial_end: trial_end,
      cancel_at_period_end: cancel_at_period_end,
      items: [
        {
          plan: plan,
        },
      ],
    )
    puts subscription # Todo: save charge infos in DB
  end

  def send_payment_confirmation(url)
    AdminMailer.new_payment(amount, stripe_email, description, url, message).deliver_later
  end

end
