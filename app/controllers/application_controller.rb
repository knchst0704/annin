class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :set_data

  private
    def set_data
      @tags = ActsAsTaggableOn::Tag.most_used(20)
      @sitename = nil
      case request.subdomain
      when 'kyonyu'
        @sitename = '巨乳ストリーム（仮）'
      else
        @sitename = 'エロストリーム'
      end
    end
end
