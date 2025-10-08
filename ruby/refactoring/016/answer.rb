class Shipping
  def initialize(weight, distance, is_member)
    @weight = weight
    @distance = distance
    @is_member = is_member
  end

  def calculate_fee
    fee = base_fee
    fee += weight_surcharge
    fee += distance_surcharge
    fee = apply_member_discount(fee)
    fee += additional_fee
    fee
  end

  def base_fee
    raise NotImplementedError, "#{self.class}#base_fee must be implemented"
  end

  def weight_threshold
    raise NotImplementedError, "#{self.class}#weight_threshold must be implemented"
  end

  def weight_rate
    raise NotImplementedError, "#{self.class}#weight_rate must be implemented"
  end

  def distance_threshold
    raise NotImplementedError, "#{self.class}#distance_threshold must be implemented"
  end

  def distance_rate
    raise NotImplementedError, "#{self.class}#distance_rate must be implemented"
  end

  def additional_fee
    0
  end

  def discount_rate
    raise NotImplementedError, "#{self.class}#discount_rate must be implemented"
  end

  private

  def weight_surcharge
    @weight > weight_threshold ? (@weight * weight_rate) : 0
  end

  def distance_surcharge
    @distance > distance_threshold ? (@distance * distance_rate) : 0
  end

  def apply_member_discount(fee)
    @is_member ? (fee * discount_rate) : fee
  end
end

class StandardShipping < Shipping
  def base_fee
    500
  end

  def weight_threshold
    5
  end

  def weight_rate
    100
  end

  def distance_threshold
    50
  end

  def distance_rate
    10
  end

  def discount_rate
    0.9
  end
end

class ExpressShipping < Shipping
  EXPRESS_FEE = 500

  def base_fee
    1000
  end

  def weight_threshold
    3
  end

  def weight_rate
    150
  end

  def distance_threshold
    30
  end

  def distance_rate
    20
  end

  def additional_fee
    EXPRESS_FEE
  end

  def discount_rate
    0.95
  end
end

class SameDayShipping < Shipping
  SAME_DAY_FEE = 1000
  MAX_DELIVERY_DISTANCE = 50

  def base_fee
    2000
  end

  def weight_threshold
    2
  end

  def weight_rate
    200
  end

  def distance_threshold
    20
  end

  def distance_rate
    30
  end

  def additional_fee
    SAME_DAY_FEE
  end

  def discount_rate
    0.95
  end

  def calculate_fee
    return nil if @distance > MAX_DELIVERY_DISTANCE
    super
  end
end

class ShippingFactory
  def self.create(shipping_type, weight, distance, is_member)
    case shipping_type
    when 'standard'
      StandardShipping.new(weight, distance, is_member)
    when 'express'
      ExpressShipping.new(weight, distance, is_member)
    when 'same_day'
      SameDayShipping.new(weight, distance, is_member)
    else
      raise ArgumentError, "Unknown shipping type: #{shipping_type}"
    end
  end
end

class ShippingCalculator
  def calculate_shipping_fee(shipping_type, weight, distance, is_member)
    shipping = ShippingFactory.create(shipping_type, weight, distance, is_member)
    shipping.calculate_fee
  end
end

calculator = ShippingCalculator.new
puts calculator.calculate_shipping_fee('standard', 10, 60, true)
puts calculator.calculate_shipping_fee('express', 4, 40, false)
puts calculator.calculate_shipping_fee('same_day', 3, 25, true)
