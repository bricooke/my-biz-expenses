class ReportsController < ApplicationController
  before_filter :login_required
  
  def name
    "report"
  end
   
  def create
    report = params[:report]
    category_condition = report[:category] == "all" ? "" : "AND category_id = #{report[:category]}"
    from = Date.parse("#{report["from(1i)"]}-#{report["from(2i)"]}-#{report["from(3i)"]}")
    to = Date.parse("#{report["to(1i)"]}-#{report["to(2i)"]}-#{report["to(3i)"]}").to_time+1.day-1
    
    args = {:conditions => ["expenses.created_at >= ? AND expenses.created_at <= ? #{category_condition}", from.to_s(:db), to.to_s(:db)], 
     :order => "expenses.created_at ASC"}
    
    if report[:tags].blank?
      @expenses = current_user.expenses.find(:all, args)
    else
      @expenses = current_user.expenses.find_tagged_with(
                                              report[:tags], 
                                              args)
    end
    
    @both = params[:report][:type] == "both"
    if params[:report][:type] == "graph" || @both
      # create the array for css_graphs. one bar for each category
      @graph = Category.report(@expenses) if @expenses.size > 0
    end
    
    @total_price = 0.0
    @expenses.each {|exp| @total_price += exp.price}
  end
end
