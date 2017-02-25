class VideosController < ApplicationController
  require 'nokogiri'
  require 'uri'
  require 'open-uri'

  def show
    @video = Video.find_by(id: params[:id])
    @video.pv += 1
    @video.save
    @related_videos = Video.tagged_with(@video.tags, any: true).where.not(id: params[:id]).limit(10)
  end

  def search
    @videos = Video.tagged_with(params[:search]).page(params[:page])
  end

  def fetch
    providers = [
      {
        "site": "ジャビま",
        "url": "http://javym.net/search/%E3%83%8A%E3%83%B3%E3%83%91/",
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
        "url": "http://www.nukistream.com/category.php?id=27",
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
        "url": "http://masutabe.info/search/%E3%83%8A%E3%83%B3%E3%83%91/",
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
        "url": "http://poyopara.com/m/search.php?keyword=%E3%83%8A%E3%83%B3%E3%83%91",
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
        "url": "http://erry.one/search/%E3%83%8A%E3%83%B3%E3%83%91/",
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
        "url": "http://iqoo.me/m/search/%E3%83%8A%E3%83%B3%E3%83%91/",
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
        "url": "http://hikaritube.com/m/search.php?keyword=%E3%83%8A%E3%83%B3%E3%83%91",
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
        v = Video.new video
        v.tag_list.add tags
        v.save!
      end
    end

    redirect_to root_path
  end
end
