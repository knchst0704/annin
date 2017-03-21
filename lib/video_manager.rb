class VideoManager
  require 'uri'

  $video_counter = 0

  def self.get_list
    markov_dic_json = File.open("#{Rails.root}/markov_dic.json") { |f| JSON.load(f) }
    dic = {}
    markov_dic_json.map { |k, v| dic[JSON.parse(k)] = v }

    providers_json = File.open("#{Rails.root}/providers.json") { |f| JSON.load(f) }
    providers = providers_json['providers']

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

        unless article.css(provider[:selectors][:thumbnail]).attribute('src').value =~ URI::regexp
          video[:thumbnail] = url + article.css(provider[:selectors][:thumbnail]).attribute('src').value
        else
          video[:thumbnail] = article.css(provider[:selectors][:thumbnail]).attribute('src').value
        end

        video[:duration] = article.css(provider[:selectors][:duration]).text
        video[:title] = included_tag_title(tags) if tags.length > 0
        video[:original_title] = article.css(provider[:selectors][:title]).text
        video[:host] = provider[:site]
        video[:link] = url + article.css(provider[:selectors][:link]).attribute('href').value
        video[:pv] = 1

        next if Video.exists?(link: video[:link])

        v = Video.new video
        v.tag_list.add tags
        v.save ? $video_counter += 1 : next
        p v
      end
    end

    create_markov_dic

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
      p player
      player.blank? ? video.destroy : video.update(player: player)
    end
  end

  def self.fetch
    get_list
    get_player
  end

  $h = {}
  def self.parse_text(text)
    return if text.nil?
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

  def self.markov(dic)
  	random = Random.new
  	prefix = ["BEGIN", "BEGIN"]
  	ret = ""
  	loop{
  		n = dic[prefix].length
  		prefix = [prefix[1], dic[prefix][random.rand(0..n-1)]]
  		ret += prefix[0] unless prefix[0] == "BEGIN"
  		if dic[prefix].last == "END"
  			ret += prefix[1]
  			break
  		end
  	}
  	# p "RESULTS: " + ret
  	return ret
  end

  def self.create_markov_dic
    Video.all.each do |video|
      parse_text(video.original_title)
    end
    open("#{Rails.root}/markov_dic.json", 'w') do |io|
      JSON.dump($h, io)
    end
  end

  def self.markov_test
    markov_dic_json = File.open("#{Rails.root}/markov_dic.json") { |f| JSON.load(f) }
    dic = {}
    markov_dic_json.map { |k, v| dic[JSON.parse(k)] = v }

    Video.all.limit(100).each do |video|
      included_tag_title(video.tag_list) if video.tag_list.length > 0
    end
  end

  def self.included_tag_title(tags)
    markov_dic_json = File.open("#{Rails.root}/markov_dic.json") { |f| JSON.load(f) }
    dic = {}
    markov_dic_json.map { |k, v| dic[JSON.parse(k)] = v }

    ret = ""
    isBreak = false
    loop {
      title = markov(dic)
      tags.each_with_index do |tag, index|
        if title.include?(tag)

          p "-" * 100
          p title
          p tags

          isBreak = true
          ret = title
          break
        end
        if index == tags.length - 1
          isBreak = true
          ret = title
          break
        end
      end
      break if isBreak
    }

    return ret
  end
end
