# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include ExceptionNotifiable
  include AuthenticatedSystem
  
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_mybizexpenses_session_id'
  
  before_filter :login_from_cookie
  
  def name
    ""
  end
  
  # via http://www.meepr.com/2006/08/02/rails-pagination-with-associations/
  def paginate_association(object, assoc_name, find_options = {}, per_page = 10)
    page = (params[:page] || 1).to_i
    
    item_count = object.send(assoc_name.to_s + '_count')
    offset = (page-1)*per_page
    
    @items = object.send(assoc_name).find(:all, {:offset => offset, :limit => per_page}.merge(find_options))
    @item_pages = Paginator.new self, item_count, per_page, page
  
    return @item_pages, @items
  end
  
end
