class CreateSomeCategories < ActiveRecord::Migration
  def self.up
  end

  def self.down
    Category.destroy_all
  end
end
