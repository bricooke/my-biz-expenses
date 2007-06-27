require File.dirname(__FILE__) + '/../test_helper'
require 'expenses_controller'

# Re-raise errors caught by the controller.
class ExpensesController; def rescue_action(e) raise e end; end

class ExpensesControllerTest < Test::Unit::TestCase
  fixtures :expenses, :categories, :users

  def setup
    @controller = ExpensesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_require_login
    get :index
    assert_response :redirect
    assert_redirected_to new_session_url
  end  
  
  def test_should_show_index
    login_as :quentin
    get :index
    assert_response :success
  end
  
  def test_should_create_expense
    login_as :quentin
    assert_no_difference Category, :count do
      assert_difference categories(:quentins_software).expenses(:refresh), :size do
        put :create, :expense => @@default_expense.merge({:category => categories(:quentins_software).name})
        assert_valid assigns(:expense)
        assert_equal assigns(:expense).errors.size, 0
        assert_redirected_to expenses_url
        # dunno why i have to force the refresh here :(
        categories(:quentins_software).expenses(:refresh)
      end
    end
  end
  
  def test_should_require_name
    login_as :quentin
    assert_no_difference Expense, :count do
      put :create, :expense => @@default_expense.merge({:name => nil})
      assert_template "index"
    end
  end
  
  def test_should_sum_expenses
    login_as :quentin
    get :index
    assert_equal assigns(:total_price), (4995.0+2995.0)/100.0
  end
  
  def test_should_delete_expense
    login_as :quentin
    assert_difference Expense, :count, -1 do
      xhr :delete, :destroy, :id => expenses(:agile_web_dev).id
      assert_response :success      
      assert_rjs :visual_effect, :fade, assigns(:dom_id)
    end
  end
  
  def test_should_edit_expense
    login_as :quentin
    assert_no_difference Expense, :count do
      xhr :get, :edit, :id => expenses(:agile_web_dev).id
      assert_response :success      
      assert_rjs :replace_html, assigns(:expense).dom_id
    end    
  end
  
  def test_should_update_expense
    login_as :quentin
    assert_no_difference Expense, :count do
      xhr :put, :update, :id => expenses(:agile_web_dev).id, :expense => {:name => "bobo"}
      assert_response :success
      assert_rjs :replace_html, assigns(:expense).dom_id
      assert_template "show"
    end    
  end
  
  def test_should_create_expense
    login_as :quentin
    assert_difference Category, :count do
      assert_difference Expense, :count do
        
        
        xhr :post, :create, :expense => {:name => "something", :category => "BozosRUs", :price => "14.95"}
        assert_response :success      
        assert_rjs :insert_html, :top, 'expenses'
        assert_rjs :visual_effect, :highlight, assigns(:expense).dom_id
      end    
    end
  end
  
end
