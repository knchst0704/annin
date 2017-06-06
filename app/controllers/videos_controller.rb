class VideosController < ApplicationController
  require 'kongo'

  def fetch
    Kongo.get_top_3
    redirect_to videos_path
  end

  def index
    @videos = Video.all
  end
end
