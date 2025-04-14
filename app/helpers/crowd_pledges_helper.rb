module CrowdPledgesHelper

  def crowd_boost_charge_amount_values(total_price)
    raw_values =
      case total_price
      when 0...50
        [0.0, 1.5, 3.0, 5.0]
      when 50..250
        [0.0, 5.0, 10.0, 20.0]
      else
        [0.0, 10.0, 25.0, 50.0]
      end
  
    default_amount = raw_values[2] # z. B. mittlerer Wert als Default
  
    values = raw_values.map do |amount|
      {
        amount: amount,
        label: "#{amount.to_i == amount ? amount.to_i : amount} €",
        default: amount == default_amount,
        is_zero: false
      }
    end
  
    values
  end  

end
