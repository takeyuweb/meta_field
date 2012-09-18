module Car
  def self.table_name_prefix
    'car_'
  end
end

require 'car/car'
require 'car/standard_size_car'
require 'car/large_size_car'
