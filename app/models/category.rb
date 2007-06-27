class Category < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => "user_id"
  has_many :expenses
  belongs_to :user
  
  # return an array of arrays: [["cat_name", sum], ["other_name", sum]]
  def self.report(expenses)
    ret = []
    
    # TODO: gotta be a smarter way?
    expenses[0].user.categories.each do |category|
      sum = 0
      expenses.each do |expense|
        if expense.category == category 
          sum += expense.price
        end
      end
      ret << [category.name, sum] if sum > 0
    end
    ret
  end
end
