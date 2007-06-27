require File.dirname(__FILE__) + '/../test_helper'

class CategoryTest < Test::Unit::TestCase
  fixtures :categories, :expenses, :users

  def test_should_increase_count_on_new_expense
    assert_difference categories(:quentins_software).expenses(:refresh), :size do
      expense = categories(:quentins_software).expenses.create(@@default_expense)
      assert_valid expense
    end
  end
  
  def test_should_report
    rep = Category.report([expenses(:wnh), expenses(:agile_web_dev)])
    assert_equal rep[0][0], "Software"
    assert_equal rep[0][1], 29.95
  end
end
