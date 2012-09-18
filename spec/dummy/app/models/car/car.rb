class Car::Car < ActiveRecord::Base
  attr_accessible :name, :price, :displacement, :note

  meta_attr :price, :integer
  meta_attr :displacement, :integer
  meta_attr :note, :text
end
