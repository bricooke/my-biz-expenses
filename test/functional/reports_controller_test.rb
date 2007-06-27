require File.dirname(__FILE__) + '/../test_helper'
require 'reports_controller'

# Re-raise errors caught by the controller.
class ReportsController; def rescue_action(e) raise e end; end

class ReportsControllerTest < Test::Unit::TestCase
  fixtures :expenses, :categories, :users, :taggings, :tags
  
  def setup
    @controller = ReportsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_sum_expenses
    login_as :quentin
    post :create, :report => {:category => "all", "from(1i)" => "2000", "from(2i)" => "01", "from(3i)" => "01", "to(1i)" => "2010", "to(2i)" => "01", "to(3i)" => "01"}
    assert_equal assigns(:total_price), (4995.0+2995.0)/100.0
  end

  def test_should_find_tagged_expense
    login_as :quentin
    assert_equal 1, expenses(:wnh).tags.size
    post :create, :report => {:category => "all", "from(1i)" => "2000", "from(2i)" => "01", "from(3i)" => "01", "to(1i)" => "2010", "to(2i)" => "01", "to(3i)" => "01", :tags => "Software, Licenses,"}
    assert_equal assigns(:expenses).size, 1
  end
  
  def test_should_not_find_any_results
    login_as :quentin
    post :create, :report => {:category => "all", "from(1i)" => "2000", "from(2i)" => "01", "from(3i)" => "01", "to(1i)" => "2000", "to(2i)" => "01", "to(3i)" => "01", :type => "both"}
    assert_equal assigns(:total_price), 0.00
  end
end
