class HomeController < ApplicationController
  def index
    @videos = Video.all.page(params[:page]).per(24)
  end
end
