# -*- coding: utf-8 -*-

# STI

describe Car::Car do
  describe "値へのアクセス" do
    let(:car){ create(:car, price: 200) }
    it{ expect{ car.seater }.to raise_error(NoMethodError) }
    it{ car.price.should == 200 }
    it{ car.update_attributes(price: 300); Car::Car.find(car.id).price.should == 300 }
  end

  describe '検索' do
    before do
      [[:standard_size_car, {price: 100}],
       [:standard_size_car, {price: 200}],
       [:standard_size_car, {price: 300}],
       [:standard_size_car, {price: 400}],
       [:standard_size_car, {price: 500}],
       [:large_size_car, {price: 100}],
       [:large_size_car, {price: 200}],
       [:large_size_car, {price: 300}],
       [:large_size_car, {price: 400}],
       [:large_size_car, {price: 500}],
       [:car, {price: 100}],
       [:car, {price: 200}],
       [:car, {price: 300}],
       [:car, {price: 400}],
       [:car, {price: 500}]].each do |type, attr|
        create(type, attr)
      end
    end
    it{ Car::Car
        .meta_join(price: Car::Car.meta[:price].lt(300))
        .order('price DESC')
        .map{|car| car.price }
        .should == [200, 200, 200, 100, 100, 100]}
    it{ Car::Car
        .meta_join(price: Car::Car.meta[:price].gt(300))
        .order('price DESC')
        .map{|car| car.price }
        .should == [500, 500, 500, 400, 400, 400]}
    it{ Car::Car
        .meta_join(price: Car::Car.meta[:price].gt(100).and(Car::Car.meta[:price].lt(500)))
        .order('price DESC')
        .map{|car| car.price }
        .should == [400, 400, 400, 300, 300, 300, 200, 200, 200]}
    it{ Car::StandardSizeCar
        .meta_join(price: Car::StandardSizeCar.meta[:price].lt(300))
        .order('price DESC')
        .map{|car| car.price }
        .should == [200, 100]}
    it{ Car::StandardSizeCar
        .meta_join(price: Car::StandardSizeCar.meta[:price].gt(300))
        .order('price DESC')
        .map{|car| car.price }
        .should == [500, 400]}
    it{ Car::StandardSizeCar
        .meta_join(price: Car::StandardSizeCar.meta[:price].gt(100).and(Car::StandardSizeCar.meta[:price].lt(500)))
        .order('price DESC')
        .map{|car| car.price }
        .should == [400, 300, 200]}
  end
end

describe Car::StandardSizeCar do
  describe "値へのアクセス" do
    let(:car){ create(:standard_size_car, seater: 7, price: 200) }
    it{ car.seater.should == 7 }
    it{ car.price.should == 200 }
    it{ car.update_attributes(price: 300); Car::StandardSizeCar.find(car.id).price.should == 300 }
    it{ car.update_attributes(seater: 5); Car::StandardSizeCar.find(car.id).seater.should == 5 }
  end

  describe '検索' do
    before do
      [{price: 100, seater: 4},
       {price: 200, seater: 4},
       {price: 300, seater: 4},
       {price: 400, seater: 4},
       {price: 500, seater: 4},
       {price: 100, seater: 5},
       {price: 200, seater: 5},
       {price: 300, seater: 5},
       {price: 400, seater: 5},
       {price: 500, seater: 5},
       {price: 100, seater: 6},
       {price: 200, seater: 6},
       {price: 300, seater: 6},
       {price: 400, seater: 6},
       {price: 500, seater: 6}].each do |attr|
        create(:standard_size_car, attr)
      end
    end
    it{ Car::StandardSizeCar
        .meta_join(price: Car::StandardSizeCar.meta[:price].lt(300),
                   seater: Car::StandardSizeCar.meta[:seater].eq(5))
        .order('price DESC')
        .map{|car| [car.price, car.seater] }
        .should == [[200, 5], [100, 5]]}
    it{ Car::StandardSizeCar
        .meta_join(price: Car::StandardSizeCar.meta[:price].gt(300),
                   seater: Car::StandardSizeCar.meta[:seater].eq(5))
        .order('price DESC')
        .map{|car| [car.price, car.seater] }
        .should == [[500, 5], [400, 5]]}
    it{ Car::StandardSizeCar
        .meta_join(price: Car::StandardSizeCar.meta[:price].gt(100).and(Car::StandardSizeCar.meta[:price].lt(500)),
                   seater: Car::StandardSizeCar.meta[:seater].eq(5))
        .order('price DESC')
        .map{|car| [car.price, car.seater] }
        .should == [[400, 5], [300, 5], [200, 5]]}
  end
end

describe Car::LargeSizeCar do
  describe "値へのアクセス" do
    let(:car){ create(:large_size_car, price: 2000) }
    it{ expect{ car.seater }.to raise_error(NoMethodError) }
    it{ car.price.should == 2000 }
    it{ car.update_attributes(price: 3000); Car::LargeSizeCar.find(car.id).price.should == 3000 }
  end
end
