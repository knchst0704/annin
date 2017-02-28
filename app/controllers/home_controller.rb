class HomeController < ApplicationController
  def index
    case params[:type]
    when 'latest'
      @videos = Video.where.not(player: nil).order(created_at: :desc).page(params[:page]).per(24)
    else
      @videos = Video.where.not(player: nil).order(pv: :desc).page(params[:page]).per(24)
    end

    set_meta_tags title: 'エロストリーム'
  end
end
