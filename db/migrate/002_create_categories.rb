class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.column :name, :string
      t.column :expenses_count, :integer, :default => 0
      t.column :default_category, :boolean, :default => false
      t.column :user_id, :integer
    end
  end

  def self.down
    drop_table :categories
  end
end
