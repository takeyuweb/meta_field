FactoryGirl.define do
  factory :book do
    sequence(:name){|i| "book#{i}" }
    association :author
  end
end
