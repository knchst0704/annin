class VideoManager
  def self.get_list
    providers = [
      {
        "site": "ジャビま",
        "url": "http://javym.net",
        "selectors": {
          "list": "article",
          "tag_list": ".tagList > li",
          "thumbnail": "figure > img",
          "duration": "figure > .duration",
          "title": "div > h2 > a",
          "link": "div > h2 > a"
        },
        "except_indexes": [0]
      },
      {
        "site": "ぬきスト",
        "url": "http://www.nukistream.com",
        "selectors": {
          "list": "article",
          "tag_list": ".article_content > ul > li",
          "thumbnail": ".thumb > a > img",
          "duration": ".thumb > a > span",
          "title": ".article_content > h3 > a",
          "link": ".thumb > a"
        },
        "except_indexes": [0]
      },
      {
        "site": "マスタベ",
        "url": "http://masutabe.info",
        "selectors": {
          "list": "article",
          "tag_list": ".tagList > li",
          "thumbnail": "figure > a > img",
          "duration": "figure > a > .duration",
          "title": "div > h2 > a",
          "link": "div > h2 > a"
        },
        "except_indexes": [0]
      },
      {
        "site": "ぽよパラ",
        "url": "http://poyopara.com/m/",
        "selectors": {
          "list": "article",
          "tag_list": ".article_content > ul > li",
          "thumbnail": ".thumb > a > img",
          "duration": ".thumb > a > span",
          "title": ".article_content > h3 > a",
          "link": ".thumb > a"
        },
        "except_indexes": [0, 1, 22, 23]
      },
      {
        "site": "ERRY",
        "url": "http://erry.one",
        "selectors": {
          "list": "article",
          "tag_list": ".tagList > li",
          "thumbnail": "figure > a > img",
          "duration": "figure > a > .duration",
          "title": "div > h2 > a",
          "link": "div > h2 > a"
        },
        "except_indexes": []
      },
      {
        "site": "iQoo",
        "url": "http://iqoo.me/m/",
        "selectors": {
          "list": "article",
          "tag_list": ".article_content > ul > li",
          "thumbnail": ".thumb > a > img",
          "duration": ".thumb > a > span",
          "title": ".article_content > h3 > a",
          "link": ".thumb > a"
        },
        "except_indexes": [0, 1, 22, 23]
      },
      {
        "site": "シコセン",
        "url": "http://hikaritube.com/m/",
        "selectors": {
          "list": "article",
          "tag_list": ".article_content > ul > li",
          "thumbnail": ".thumb > a > img",
          "duration": ".thumb > a > span",
          "title": ".article_content > h3 > a",
          "link": ".thumb > a"
        },
        "except_indexes": [0, 1, 22, 23]
      }
    ]

    providers.each do |provider|
      uri = URI.parse(provider[:url])
      url = "#{uri.scheme}://#{uri.host}"
      html = open(provider[:url]) { |f| f.read }
      doc = Nokogiri::HTML.parse(html, nil, 'utf-8')

      articles = doc.search(provider[:selectors][:list])
      articles.each_with_index do |article, index|
        next if provider[:except_indexes].include?(index)
        tags = []
        article.css(provider[:selectors][:tag_list]).each { |tag| tags << tag.css('a').text }
        video = {}
        if provider[:site] == 'ERRY'
          video[:thumbnail] = url + article.css(provider[:selectors][:thumbnail]).attribute('src').value
        else
          video[:thumbnail] = article.css(provider[:selectors][:thumbnail]).attribute('src').value
        end
        video[:duration] = article.css(provider[:selectors][:duration]).text
        video[:title] = article.css(provider[:selectors][:title]).text
        video[:host] = provider[:site]
        video[:link] = url + article.css(provider[:selectors][:link]).attribute('href').value

        next if Video.exists?(link: video[:link])

        v = Video.new video
        v.tag_list.add tags
        v.pv = 1
        v.save!
        p video
      end
    end
  end

  def self.get_player
    Video.where(player: nil).where.not(link: nil).each do |video|
      html = open(video.link) { |f| f.read }
      doc = Nokogiri::HTML.parse(html, nil, 'utf-8')
      player = doc.css('#player > iframe').to_html
      player = doc.css('#player > li > iframe').to_html if player.blank?
      player = doc.css('#player > ul > li > iframe').to_html if player.blank?

      if player.blank?
        video.destroy
      else
        video.update(player: player)
        p video
      end
    end
  end
end
