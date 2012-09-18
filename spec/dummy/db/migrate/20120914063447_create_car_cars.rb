class CreateCarCars < ActiveRecord::Migration
  def change
    create_table :car_cars do |t|
      t.string :name
      t.string :type

      t.timestamps
    end
  end
end
