class UptimeController < ApplicationController
  def success
    if false # add any db checks or anything you want here
      render :text => "failure"
    else
      render :text => "success"
    end
  end
end
