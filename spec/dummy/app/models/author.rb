class Author < ActiveRecord::Base
  attr_accessible :name

  meta_field :age, :integer
  meta_attr :sex, :integer # alias for meta_field

  SEX_MALE = 0
  SEX_FEMALE = 1
end
