class VideosController < ApplicationController
  require 'video_manager'

  def show
    @video = Video.find_by(id: params[:id])
    @video.pv += 1
    @video.save
    @related_videos = Video.tagged_with(@video.tags, any: true).where.not(id: params[:id]).order(pv: :desc).limit(10)

    set_meta_tags site: @sitename, title: @video.title, reverse: true
  end

  def search
    @videos = Video.tagged_with(params[:search]).order(pv: :desc).page(params[:page])

    set_meta_tags site: @sitename, title: "『#{params[:search]}』がついた動画", reverse: true
  end

  def report
    link = request.base_url + video_path(id: params[:id])
    notifier = Slack::Notifier.new "https://hooks.slack.com/services/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"
    notifier.post text: "見れない動画の報告がありました。 <#{link}|確認する>/<#{link + '/delete'}|削除する>", icon_emoji: ":ghost:", username: "エロストBOT"
    redirect_to video_path
  end

  def delete
    @video = Video.find_by(id: params[:id])
    @video.destroy
    redirect_to root_path
  end

  def fetch
    VideoManager.get_list
    VideoManager.get_player
    redirect_to root_path
  end
end
