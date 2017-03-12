class VideoManager

  $h = {}
  $video_counter = 0

  def self.get_list
    Video.all.each { |video| parse_text(video.original_title) }

    file = File.open("#{Rails.root}/providers.json") { |f| JSON.load(f) }
    providers = file['providers']

    providers.each do |provider|
      provider.deep_symbolize_keys!
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
        video[:title] = markov()
        video[:original_title] = article.css(provider[:selectors][:title]).text
        video[:host] = provider[:site]
        video[:link] = url + article.css(provider[:selectors][:link]).attribute('href').value
        video[:pv] = 1

        next if Video.exists?(link: video[:link])

        v = Video.new video
        v.tag_list.add tags
        v.save!
        $video_counter += 1
      end
    end

    notifier = Slack::Notifier.new "https://hooks.slack.com/services/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"
    notifier.post text: "#{$video_counter}本のビデオを新規に追加しました！", icon_emoji: ":ghost:", username: "エロストBOT"
  end

  def self.get_player
    Video.where(player: nil).where.not(link: nil).each do |video|
      html = open(video.link) { |f| f.read }
      doc = Nokogiri::HTML.parse(html, nil, 'utf-8')
      player = doc.css('#player > iframe').to_html
      player = doc.css('#player > li > iframe').to_html if player.blank?
      player = doc.css('#player > ul > li > iframe').to_html if player.blank?
      player.blank? ? video.destroy : video.update(player: player)
    end
  end

  def self.parse_text(text)
  	mecab = Natto::MeCab.new
  	text = text.strip
  	data = ["BEGIN", "BEGIN"]
  	mecab.parse(text) { |a| data << a.surface unless a.surface.nil? }
  	data << "END"
  	data.each_cons(3).each do |a|
  		suffix = a.pop
  		prefix = a
  		$h[prefix] ||= []
  		$h[prefix] << suffix
  	end
  end

  def self.markov()
  	random = Random.new
  	prefix = ["BEGIN", "BEGIN"]
  	ret = ""
  	loop{
  		n = $h[prefix].length
  		prefix = [prefix[1] , $h[prefix][random.rand(0..n-1)]]
  		ret += prefix[0] if prefix[0] != "BEGIN"
  		if $h[prefix].last == "END"
  			ret += prefix[1]
  			break
  		end
  	}
  	p "Result: " + ret
  	return ret
  end
end
