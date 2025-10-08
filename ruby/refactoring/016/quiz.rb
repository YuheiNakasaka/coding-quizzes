class ShippingCalculator
  def calculate_shipping_fee(shipping_type, weight, distance, is_member)
    if shipping_type == 'standard'
      base_fee = 500
      base_fee += weight * 100 if weight > 5
      base_fee += distance * 10 if distance > 50
      base_fee *= 0.9 if is_member
      base_fee
    elsif shipping_type == 'express'
      base_fee = 1000
      base_fee += weight * 150 if weight > 3
      base_fee += distance * 20 if distance > 30
      base_fee *= 0.95 if is_member
      base_fee += 500
      base_fee
    elsif shipping_type == 'same_day'
      base_fee = 2000
      base_fee += weight * 200 if weight > 2
      base_fee += distance * 30 if distance > 20
      base_fee *= 0.95 if is_member
      base_fee += 1000
      return nil if distance > 50

      base_fee
    else
      raise ArgumentError, "Unknown shipping type: #{shipping_type}"
    end
  end
end

calculator = ShippingCalculator.new
puts calculator.calculate_shipping_fee('standard', 10, 60, true)
puts calculator.calculate_shipping_fee('express', 4, 40, false)
puts calculator.calculate_shipping_fee('same_day', 3, 25, true)
