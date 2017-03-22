class HomeController < ApplicationController
  def index
    case params[:type]
    when 'latest'
      @videos = Video.subdomain(request.subdomain).where.not(player: nil).order(created_at: :desc).page(params[:page]).per(24)
    else
      @videos = Video.subdomain(request.subdomain).where.not(player: nil).where(created_at: (Time.zone.now - 1.day)..Time.zone.now).order(pv: :desc).page(params[:page]).per(24)
    end

    set_meta_tags(title: @sitename + " | 無料エロ動画まとめ")
  end
end
