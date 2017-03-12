class VideoManager
  def self.get_list
    self.title # make dic

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

  $h = {}
  def self.title
    Video.all.each do |video|
      parse_text(video.original_title)
    end
  end

  def self.parse_text(text)
  	mecab = Natto::MeCab.new
  	text = text.strip
  	data = ["BEGIN", "BEGIN"]
  	mecab.parse(text) do |a|
  		if a.surface != nil
  			data << a.surface
  		end
  	end
  	data << "END"
  	p data
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
