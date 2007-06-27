class ExpensesController < ApplicationController
  before_filter :login_required, :load_expenses

  def name
    "expenses"
  end
  
  def index
  end
  
  def create
    cat = params[:expense].delete(:category)
    @category = current_user.categories.find_or_create_by_name(cat)
    @expense = current_user.expenses.build(params[:expense].merge({:category => @category}))
    
    if @expense.save && @category.save
      respond_to do |format|
        format.html {redirect_to expenses_url}
        format.js   # load the create.rjs
      end
    else
      respond_to do |format|
        format.html {render :action => "index"}
        format.js   {render :action => "error.rjs"}
      end
    end
  end

  def show
  end
  
  def edit
  end
  
  def update
    cat = params[:expense].delete(:category)
    @category = current_user.categories.find_or_create_by_name(cat)
    @expense.update_attributes(params[:expense].merge({:category => @category}))
    
    # reload after update
    load_expenses
    
    render :action => "show"
  end
  
  def destroy
    @dom_id = ""
    if @expense 
      @dom_id = @expense.dom_id
      @expense.destroy
    end
  end  
  
  def auto_complete_for_expense_category
    @categories = current_user.categories.find(
                        :all,
                        :conditions => [ 'LOWER(name) LIKE ?','%' + params[:expense][:category].downcase + '%' ],
                        :limit => 8)
    render :partial => 'autocomplete_categories'
  end
protected

  def load_expenses
    @expense = Expense.find(params[:id]) if params[:id]
    
    @expense_pages, @expenses = paginate_association(current_user, :expenses, {:order => 'created_at DESC'}, 25)
    @total_price = 0.0
    @expenses.each {|exp| @total_price += exp.price}
    @categories = current_user.categories
  end
end