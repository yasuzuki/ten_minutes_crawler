require 'cgi'

def page_source
  `/usr/local/bin/wget -q -O- http://crawler.sbcr.jp/samplepage.html `
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

def format_text contents
  text = ""
  contents.each do |url, title, date|
    text << "#{date}: #{title}\n"
    text << "#{url}\n"
  end
  text
end
