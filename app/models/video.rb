class Video < ApplicationRecord
  acts_as_taggable
  acts_as_taggable_on :tags

  scope :subdomain, ->(subdomain) {
    case subdomain
    when 'kyonyu'
      tagged_with("巨乳")
    else
      return
    end
  }
end
