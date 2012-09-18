class Car::StandardSizeCar < Car::Car
  attr_accessible :seater
  meta_attr :seater, :integer, index: false
end
