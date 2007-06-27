require File.dirname(__FILE__) + '/../test_helper'

class ExpenseTest < Test::Unit::TestCase
  fixtures :expenses

  def test_should_get_a_price
    assert_equal expenses(:wnh).price, 29.95
  end
  
  def test_should_tag_expense
    assert_difference Tag, :count, 2 do
      assert expenses(:agile_web_dev).tag_list.empty?
      expenses(:agile_web_dev).tag_list = "Funny, Silly"
      expenses(:agile_web_dev).save
      assert !expenses(:agile_web_dev).tag_list.empty?
    end
  end
end
