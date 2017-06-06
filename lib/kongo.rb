class Kongo
  require 'uri'

  def self.get_top_3
    providers_json = File.open("#{Rails.root}/providers.json") { |f| JSON.load(f) }
    providers = providers_json['providers']
    $videos = []

    providers.each do |provider|
      provider.deep_symbolize_keys!
      uri = URI.parse(provider[:url])
      url = "#{uri.scheme}://#{uri.host}"
      html = open(provider[:ranking_url]) { |f| f.read }
      doc = Nokogiri::HTML.parse(html, nil, 'utf-8')

      articles = doc.search(provider[:selectors][:list])
      articles.each_with_index do |article, index|
        break if index >= 3
        tags = []
        article.css(provider[:selectors][:tag_list]).each { |tag| tags << tag.css('a').text }
        video = {}

        unless article.css(provider[:selectors][:thumbnail]).attribute('src').value =~ URI::regexp
          video[:thumbnail] = url + article.css(provider[:selectors][:thumbnail]).attribute('src').value
        else
          video[:thumbnail] = article.css(provider[:selectors][:thumbnail]).attribute('src').value
        end
        video[:tags] = tags
        video[:duration] = article.css(provider[:selectors][:duration]).text
        video[:title] = article.css(provider[:selectors][:title]).text
        video[:host] = provider[:site]
        video[:link] = url + article.css(provider[:selectors][:link]).attribute('href').value

        detail_html = open(video[:link]) { |f| f.read }
        detail_doc = Nokogiri::HTML.parse(detail_html, nil, 'utf-8')
        player = detail_doc.css('#player > iframe').to_html
        player = detail_doc.css('#player > li > iframe').to_html if player.blank?
        player = detail_doc.css('#player > ul > li > iframe').to_html if player.blank?

        video[:player] = player

        $videos << video
      end
    end

    Video.all.delete_all
    $videos.each do |video|
      v = Video.new
      v.title = video[:title]
      v.thumbnail = video[:thumbnail]
      v.link = video[:link]
      v.duration = video[:duration]
      v.host = video[:host]
      v.player = video[:player]
      v.tags = video[:tags].join(',') if video[:tags].count > 0
      v.save!
      p v
    end
  end
end
