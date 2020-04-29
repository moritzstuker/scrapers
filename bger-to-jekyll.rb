require 'rubygems'
require 'nokogiri'
require 'open-uri'

class ATF
  attr_accessor :title, :link

  def initialize(title, link)
    @title = title
    @link = 'http://relevancy.bger.ch' + link
    @year = title.split(' ')[0]
    @volume = title.split(' ')[1]
    @page = title.split(' ')[2]
  end

  def regeste
    regesteURL = @link.sub('index.php?', 'index.php?lang=fr&type=show_document&').sub('&lang=fr&zoom=&type=show_document', '%3Aregeste')
    return Nokogiri::HTML(open(regesteURL)).at_css('.paraatf')
  end

  def reference
    return Nokogiri::HTML(open(@link)).css('.paraatf')[1]
  end

  def toFile
    output = "---" + "\n"
    output += "layout: regeste" + "\n"
    output += "title: " + @title + "\n"
    output += "year: " + @year + "\n"
    output += "volume: " + @volume + "\n"
    output += "page: " + @page + "\n"
    output += "reference: " + self.reference + "\n"
    output += "link: " + @link + "\n"
    output += "---" + "\n"
    output += self.regeste
    return output
  end
end

year = "136"
volume = "IV"

BASE_URL = "http://relevancy.bger.ch/php/clir/http/index_atf.php?year=#{year}&volume=#{volume}&lang=fr&system=clir"

page = Nokogiri::HTML(open(BASE_URL))
links = page.css('ol li a')

links.each do |link|
  filename = link.text.gsub(' ', '-') + ".md"
  if !File.file?(filename)
    puts "Creating #{filename}..."
    f = File.new(filename, 'a')
    atf = ATF.new(link.text, link['href'])
    f.write(atf.toFile)
    f.close
  end
end

puts "Done!"
