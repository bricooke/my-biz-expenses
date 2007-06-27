class CreateExpenses < ActiveRecord::Migration
  def self.up
    create_table :expenses do |t|
      t.column :name, :string
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :price_in_cents, :integer
      t.column :category_id, :integer
      t.column :user_id, :integer
    end
  end

  def self.down
    drop_table :expenses
  end
end
