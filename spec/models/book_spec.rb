# -*- coding: utf-8 -*-
require 'spec_helper'

describe Book do
  describe 'メタデータのデフォルト値' do
    it{ build(:book).note.should == '（特になし）' }
    it{ create(:book).note.should == '（特になし）' }
    it{ book = create(:book); Book.find(book.id).note.should == '（特になし）' }
    it{ build(:book, note: 'デフォルト値の上書き').note.should == 'デフォルト値の上書き' }
    it{ create(:book, note: 'デフォルト値の上書き').note.should == 'デフォルト値の上書き' }
    it{ book = create(:book, note: 'デフォルト値の上書き'); Book.find(book.id).note.should == 'デフォルト値の上書き' }
  end

  describe 'インデックス利用不可・不可' do
    it ':text' do
      Book.send(:meta_field, :textdata, :text, index: true)
      Book.meta_fields[:textdata][1][:index].should be_false
    end
    it ':binary' do
      Book.send(:meta_field, :binarydata, :binary, index: true)
      Book.meta_fields[:binarydata][1][:index].should be_false
    end
    it ':integer' do
      Book.send(:meta_field, :integerdata1, :integer, index: true)
      Book.meta_fields[:integerdata1][1][:index].should be_true
    end
    it ':integer' do
      Book.send(:meta_field, :integerdata2, :integer)
      Book.meta_fields[:integerdata2][1][:index].should be_true
    end
  end

  describe '異なるデータ型のJOIN' do
    before do
      [{page: 200, released_at: Time.mktime(2012, 1, 1)},
       {page: 200, released_at: Time.mktime(2012, 10, 1)},
       {page: 300, released_at: Time.mktime(2012, 3, 1)},
       {page: 400, released_at: Time.mktime(2012, 8, 1)},
       {page: 400, released_at: Time.mktime(2012, 5, 1)},
       {page: 300, released_at: Time.mktime(2012, 6, 1)},
       {page: 500, released_at: Time.mktime(2012, 7, 1)},
       {page: 500, released_at: Time.mktime(2012, 4, 1)},
       {page: 100, released_at: Time.mktime(2012, 9, 1)},
       {page: 400, released_at: Time.mktime(2012, 2, 1)}].each do |attr|
        create(:book, attr)
      end
    end

    it("use index"){ Book.meta_join(:page).meta_join(:released_at).order('released_at ASC')
        .map{|book| [book.page, book.released_at]}.should =~ [[200, Time.mktime(2012, 1, 1)],
                                                              [400, Time.mktime(2012, 2, 1)],
                                                              [300, Time.mktime(2012, 3, 1)],
                                                              [500, Time.mktime(2012, 4, 1)],
                                                              [400, Time.mktime(2012, 5, 1)],
                                                              [300, Time.mktime(2012, 6, 1)],
                                                              [500, Time.mktime(2012, 7, 1)],
                                                              [400, Time.mktime(2012, 8, 1)],
                                                              [100, Time.mktime(2012, 9, 1)],
                                                              [200, Time.mktime(2012, 10, 1)]]}
  end

  describe 'モデル同士のJOINとの組み合わせ' do
    before do
      [{ book: {page: 200, released_at: Time.mktime(2012, 1, 1)},
         author: {age: 20}},
       { book: {page: 200, released_at: Time.mktime(2012, 10, 1)},
         author: {age: 20}},
       { book: {page: 300, released_at: Time.mktime(2012, 3, 1)},
         author: {age: 25}},
       { book: {page: 400, released_at: Time.mktime(2012, 8, 1)},
         author: {age: 25}},
       { book: {page: 400, released_at: Time.mktime(2012, 5, 1)},
         author: {age: 30}},
       { book: {page: 300, released_at: Time.mktime(2012, 6, 1)},
         author: {age: 30}},
       { book: {page: 500, released_at: Time.mktime(2012, 7, 1)},
         author: {age: 30}},
       { book: {page: 500, released_at: Time.mktime(2012, 4, 1)},
         author: {age: 35}},
       { book: {page: 100, released_at: Time.mktime(2012, 9, 1)},
         author: {age: 35}},
       { book: {page: 400, released_at: Time.mktime(2012, 2, 1)},
         author: {age: 40}}].each do |attrs|
        author = create(:author, attrs[:author])
        create(:book, attrs[:book].merge(author: author))
      end
    end

    it "サブクエリで対処する" do
      # "21歳から39歳の著者の本を出版日の降順で取り出す"
      books_table = Book.arel_table
      selected_authors_table = Author.meta_join(age: Author.meta[:age].gt(20).and(Author.meta[:age].lt(40))).arel.as('selected_authors')

      sql = Book.meta_join(:released_at).arel
        .join(selected_authors_table, Arel::Nodes::InnerJoin)
        .on(books_table[:author_id].eq(selected_authors_table[:id]))
        .order('released_at DESC').to_sql
      books = Book.find_by_sql(sql)

      books.map{|book| [book.released_at, book.author.age] }
        .should == [[Time.mktime(2012, 9, 1), 35],
                    [Time.mktime(2012, 8, 1), 25],
                    [Time.mktime(2012, 7, 1), 30],
                    [Time.mktime(2012, 6, 1), 30],
                    [Time.mktime(2012, 5, 1), 30],
                    [Time.mktime(2012, 4, 1), 35],
                    [Time.mktime(2012, 3, 1), 25]]
    end
  end
end
