class Api::VideosController < ApplicationController
  require 'video_manager'

  def index
    @videos = Video.all.limit(100)
  end

  def show
    @video = Video.find_by(id: params[:id])
    @video.pv += 1
    @video.save
    @related_videos = Video.tagged_with(@video.tags, any: true).where.not(id: params[:id]).limit(10)
  end

  def tag
    @videos = Video.tagged_with(params[:name]).page(params[:page])
  end
end
