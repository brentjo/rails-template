class DashboardController < ApplicationController

  def show
    response.headers["Cross-Origin-Opener-Policy"] = "setfromcontroller"
    render 'dashboard/show'
  end

end
