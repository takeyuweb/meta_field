FactoryGirl.define do
  factory :car, class: Car::Car do
    sequence(:name){|i| "car#{i}" }
  end

  factory :standard_size_car, class: Car::StandardSizeCar do
    sequence(:name){|i| "standard size car#{i}" }
  end

  factory :large_size_car, class: Car::LargeSizeCar do
    sequence(:name){|i| "large size car#{i}" }
  end
end
