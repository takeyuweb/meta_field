class MetaFieldMigration < ActiveRecord::Migration
  def change
    create_table :meta_field_metas do |t|
      t.integer :obj_id
      t.string :obj_type
      t.string :basename

      t.string :string
      t.text :text
      t.integer :integer
      t.float :float
      t.decimal :decimal
      t.datetime :datetime
      t.timestamp :timestamp
      t.time :time
      t.date :date
      t.binary :binary
      t.boolean :boolean
      t.string :indexed_string
      t.integer :indexed_integer
      t.float :indexed_float
      t.decimal :indexed_decimal
      t.datetime :indexed_datetime
      t.timestamp :indexed_timestamp
      t.time :indexed_time
      t.date :indexed_date
      t.boolean :indexed_boolean
    end
    add_index :meta_field_metas, [:obj_id, :obj_type]
    add_index :meta_field_metas, [:obj_id, :obj_type, :basename]

    add_index :meta_field_metas, :indexed_string
    add_index :meta_field_metas, :indexed_integer
    add_index :meta_field_metas, :indexed_float
    add_index :meta_field_metas, :indexed_decimal
    add_index :meta_field_metas, :indexed_datetime
    add_index :meta_field_metas, :indexed_timestamp
    add_index :meta_field_metas, :indexed_time
    add_index :meta_field_metas, :indexed_date
    add_index :meta_field_metas, :indexed_boolean
  end
end
