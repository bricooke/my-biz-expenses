class Expense < ActiveRecord::Base
  acts_as_taggable
  
  validates_presence_of :name, :category_id, :price_in_cents
  validates_numericality_of :price_in_cents
  validates_associated :category
  
  belongs_to :category, :counter_cache => true
  belongs_to :user, :counter_cache => true
  
  
protected
  def validate
    errors.add :price, "should be at least 0.01" if price_in_cents.nil? || price_in_cents < 01
  end
end
