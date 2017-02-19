class HomeController < ApplicationController
  def index
    @videos = Video.all.page(params[:page]).per(24)
    @tags = ActsAsTaggableOn::Tag.most_used(20)
  end
end
