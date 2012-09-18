# -*- coding: utf-8 -*-
require 'spec_helper'

describe Author, '値のセット' do
  describe '新規作成時のメタデータ' do
    let(:author){ build(:author) }
    it{ author.age.should be_nil }
    it{ author.age = 36; author.age.should == 36 }
    it{ create(:author, age: 36).age.should == 36 }
  end

  describe '既存レコードへの新規メタデータ' do
    let(:author){ create(:author) }
    it{ author.age.should be_nil }
    it{ author.age = 36; author.age.should == 36 }
    it{ author.age = 36; author.reload.age.should be_nil }
    it{ author.age = 36; author.save; author.reload.age.should == 36 }
  end

  describe 'メタデータの上書き' do
    let(:author){ create(:author, age: 20) }
    it{ author.age = 36; author.age.should == 36 }
    it{ author.age = 36; author.reload.age.should == 20 }
    it{ author.age = 36; author.save; author.reload.age.should == 36 }
    it{ author.age = nil; author.age.should be_nil }
    it{ author.age = nil; author.reload.age.should == 20 }
    it{ author.age = nil; author.save; author.reload.age.should be_nil }
  end
end

describe Author, 'メタデータでの検索・ソート' do
  before do
    [
     {name: 'YAMADA HANAKO', age: 20, sex: Author::SEX_FEMALE},
     {name: 'SATOU KUMI', age: 30, sex: Author::SEX_FEMALE},
     {name: 'TANAKA MAKI', age: 24, sex: Author::SEX_FEMALE},
     {name: 'YAMADA TAROU', age: 36, sex: Author::SEX_MALE},
     {name: 'INOUE KEN', age: 22, sex: Author::SEX_MALE},
     {name: 'YAMAMOTO ICHIRO', age: 34, sex: Author::SEX_MALE},
     {name: 'SATOU KUMI', age: 40, sex: Author::SEX_FEMALE},
     {name: 'MAKI IZUMI', age: 36, sex: Author::SEX_FEMALE},
     {name: 'YAMADA RYOKO', age: 48, sex: Author::SEX_FEMALE},
     {name: 'EZAKI YUUKA', age: 20, sex: Author::SEX_MALE}].each do |attrs|
      create :author, attrs
    end
  end
  describe 'meta_join' do
    it{ Author.meta_join(:age).order('age ASC').map{|author| author.age}.should == [20, 20, 22, 24, 30, 34, 36, 36, 40, 48] }
    it{ Author.meta_join(:age).order('age DESC').map{|author| author.age}.should == [48, 40, 36, 36, 34, 30, 24, 22, 20, 20] }
    it{ Author.meta_join(:sex).meta_join(:age).order('sex ASC, age ASC').
      map{|author| [author.sex, author.age]}.should == [[Author::SEX_MALE, 20],
                                                        [Author::SEX_MALE, 22],
                                                        [Author::SEX_MALE, 34],
                                                        [Author::SEX_MALE, 36],
                                                        [Author::SEX_FEMALE, 20],
                                                        [Author::SEX_FEMALE, 24],
                                                        [Author::SEX_FEMALE, 30],
                                                        [Author::SEX_FEMALE, 36],
                                                        [Author::SEX_FEMALE, 40],
                                                        [Author::SEX_FEMALE, 48]] }
    it{ Author.meta_join(:sex).meta_join(:age).order('sex DESC, age ASC').
      map{|author| [author.sex, author.age]}.should == [[Author::SEX_FEMALE, 20],
                                                        [Author::SEX_FEMALE, 24],
                                                        [Author::SEX_FEMALE, 30],
                                                        [Author::SEX_FEMALE, 36],
                                                        [Author::SEX_FEMALE, 40],
                                                        [Author::SEX_FEMALE, 48],
                                                        [Author::SEX_MALE, 20],
                                                        [Author::SEX_MALE, 22],
                                                        [Author::SEX_MALE, 34],
                                                        [Author::SEX_MALE, 36]] }
    it{ Author.meta_join(:sex).meta_join(:age).order('sex ASC, age DESC').
      map{|author| [author.sex, author.age]}.should == [[Author::SEX_MALE, 36],
                                                        [Author::SEX_MALE, 34],
                                                        [Author::SEX_MALE, 22],
                                                        [Author::SEX_MALE, 20],
                                                        [Author::SEX_FEMALE, 48],
                                                        [Author::SEX_FEMALE, 40],
                                                        [Author::SEX_FEMALE, 36],
                                                        [Author::SEX_FEMALE, 30],
                                                        [Author::SEX_FEMALE, 24],
                                                        [Author::SEX_FEMALE, 20]] }
    it{ Author.meta_join(:sex).meta_join(:age).order('sex DESC, age DESC').
      map{|author| [author.sex, author.age]}.should == [[Author::SEX_FEMALE, 48],
                                                        [Author::SEX_FEMALE, 40],
                                                        [Author::SEX_FEMALE, 36],
                                                        [Author::SEX_FEMALE, 30],
                                                        [Author::SEX_FEMALE, 24],
                                                        [Author::SEX_FEMALE, 20],
                                                        [Author::SEX_MALE, 36],
                                                        [Author::SEX_MALE, 34],
                                                        [Author::SEX_MALE, 22],
                                                        [Author::SEX_MALE, 20]] }
    it{ Author.meta_join(:sex, :age).order('sex ASC, age ASC').
      map{|author| [author.sex, author.age]}.should == [[Author::SEX_MALE, 20],
                                                        [Author::SEX_MALE, 22],
                                                        [Author::SEX_MALE, 34],
                                                        [Author::SEX_MALE, 36],
                                                        [Author::SEX_FEMALE, 20],
                                                        [Author::SEX_FEMALE, 24],
                                                        [Author::SEX_FEMALE, 30],
                                                        [Author::SEX_FEMALE, 36],
                                                        [Author::SEX_FEMALE, 40],
                                                        [Author::SEX_FEMALE, 48]] }
    it{ Author.meta_join(:sex).meta_join(age: Author.meta[:age].gt(20).and(Author.meta[:age].lt(40))).order('sex ASC, age ASC').
      map{|author| [author.sex, author.age]}.should == [[Author::SEX_MALE, 22],
                                                        [Author::SEX_MALE, 34],
                                                        [Author::SEX_MALE, 36],
                                                        [Author::SEX_FEMALE, 24],
                                                        [Author::SEX_FEMALE, 30],
                                                        [Author::SEX_FEMALE, 36]] }

    describe '通常のカラムとメタデータの組み合わせ検索' do
      it '先にJOINして、where句で検索' do
        t = Author.arel_table
        Author.meta_join(:age).where(t[:name].matches('YAMADA %').and(Arel.sql('age < 40'))).order('age ASC').
          map{|author| author.name}.should == ['YAMADA HANAKO', 'YAMADA TAROU']
      end

      it 'メタデータの絞り込みをしてからJOIN' do
        t = Author.arel_table
        Author.meta_join(age: Author.meta[:age].lt(40)).where(t[:name].matches('YAMADA %')).order('age ASC').
          map{|author| author.name}.should == ['YAMADA HANAKO', 'YAMADA TAROU']
      end
    end

  end
end

describe Author, 'メタデータの削除' do
  let(:author){ create(:author, age: 36, sex: Author::SEX_MALE) }
  before{ author; create(:author, age: 40, sex: Author::SEX_FEMALE) }
  it{ author.destroy.should be_true }
  it{ expect{ author.destroy }.to change(MetaField::Meta, :count).by(-2) }
end
