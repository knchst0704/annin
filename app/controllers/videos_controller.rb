class VideosController < ApplicationController
  require 'kongo'

  def fetch
    render json: {
      data: Kongo.get_top_3
    }
  end
end
