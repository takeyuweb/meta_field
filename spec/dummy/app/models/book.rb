# -*- coding: utf-8 -*-
class Book < ActiveRecord::Base
  belongs_to :author
  attr_accessible :name, :author_id

  meta_field :released_at, :datetime, index: true
  meta_field :page, :integer
  meta_field :note, :text, default: '（特になし）'
end
