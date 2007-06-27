class AddTags < ActiveRecord::Migration
  def self.up
    create_table :tags, :force => true do |t|
      t.column :name, :string
    end

    create_table :taggings, :force => true do |t|
      t.column :tag_id, :integer
      t.column :taggable_id, :integer
      t.column :taggable_type, :string
      t.column :created_at, :datetime
    end

    create_table :expenses_tags, :id => false, :force => true do |t|
      t.column :tag_id, :integer, :default => "0", :null => false
      t.column :expense_id, :integer, :default => 0, :null => false
    end
  end

  def self.down
    drop_table "tags"
    drop_table "taggings"
    drop_table "expenses_tags"
  end
end
