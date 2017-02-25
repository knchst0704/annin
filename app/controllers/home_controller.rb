class HomeController < ApplicationController
  def index
    case params[:type]
    when 'latest'
      @videos = Video.all.order(created_at: :desc).page(params[:page]).per(24)
    else
      @videos = Video.all.order(pv: :desc).page(params[:page]).per(24)
    end
  end
end
