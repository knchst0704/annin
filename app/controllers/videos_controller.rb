class VideosController < ApplicationController
  require 'video_manager'

  def show
    @video = Video.find_by(id: params[:id])
    @video.pv += 1
    @video.save
    @related_videos = Video.tagged_with(@video.tags, any: true).where.not(id: params[:id]).limit(10)
  end

  def search
    @videos = Video.tagged_with(params[:search]).page(params[:page])
  end

  def fetch
    VideoManager.get_list
    VideoManager.get_player
    redirect_to root_path
  end
end
