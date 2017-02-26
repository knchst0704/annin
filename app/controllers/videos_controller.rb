class VideosController < ApplicationController
  require 'nokogiri'
  require 'uri'
  require 'open-uri'

  def show
    @video = Video.find_by(id: params[:id])
    @video.pv += 1
    @video.save
    @related_videos = Video.tagged_with(@video.tags, any: true).where.not(id: params[:id]).limit(10)
  end

  def search
    @videos = Video.tagged_with(params[:search]).page(params[:page])
  end
end
