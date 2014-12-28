require 'cgi'
require 'open-uri'
require 'rss'

CRAWLING_URL = 'http://crawler.sbcr.jp/samplepage.html'

def page_source
  open(CRAWLING_URL, 'r:UTF-8' , &:read)
end

def parse(page_source)
  dates = page_source.scan(%r{(\d+)年 ?(\d+)月 ?(\d+)日<br />})
  url_titles = page_source.scan(%r{^<a href="(.+)?">(.+?)</a><br />})
  contents = url_titles.zip(dates)

  contents.map do |(url, title), date|
    [
      CGI.unescapeHTML(url),
      CGI.unescapeHTML(title),
      Time.local(*date)
    ]
  end
end

def contents
  parse page_source
end

def header
  [
    CRAWLING_URL,
    "www.SBCR.JP トピックス",
  ]
end

def format_text contents
  text = ""
  contents.each do |url, title, date|
    text << "#{date}: #{title}\n"
    text << "#{url}\n"
  end
  text
end

def format_rss url, title, contents
  RSS::Maker.make('2.0') do |maker|
    maker.channel.updated = Time.now.to_s
    maker.channel.link = url
    maker.channel.title = title
    maker.channel.description = title
    contents.each do |url, title, date|
      maker.items.new_item do |item|
        item.link = url
        item.title = title
        item.updated = date
        item.description = title
      end
    end
  end
end
