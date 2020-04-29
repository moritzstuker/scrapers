require 'rubygems'
require 'nokogiri'
require 'open-uri'

class ATF
  def initialize(title, link)
    @title = title
    @link = 'http://relevancy.bger.ch' + link
  end

  def regeste
    regesteURL = @link.sub('index.php?', 'index.php?lang=fr&type=show_document&').sub('&lang=fr&zoom=&type=show_document', '%3Aregeste')
    return Nokogiri::HTML(open(regesteURL)).at_css('.paraatf')
  end

  def build
    return "**ATF " + @title + "** • " + self.regeste
  end
end

def url(year, vol)
  return "http://relevancy.bger.ch/php/clir/http/index_atf.php?year=#{year}&volume=#{vol}&lang=fr&system=clir"
end

dir = Dir.pwd + "/output/"

years = []

scopeEnd = 2018 - 1874
scopeStart = scopeEnd - 10

(scopeStart..scopeEnd).each do |y|
  years.push(y.to_s)
end

volumes = ["I", "II", "III", "IV", "V"]

volumes.each do |volume|

  case volume
  when "I"
    volName = "Droit constitutionnel"
  when "II"
    volName = "Droit administratif"
  when "III"
    volName = "Droit civil, poursuite et faillite"
  when "IV"
    volName = "Droit pénal et exécution de peine"
  when "V"
    volName = "Droit des assurances sociales"
  end


  filename = volName + ".md"

  if !File.file?(dir + filename)
    puts "Creating #{dir + filename}..."
    f = File.new(dir + filename, 'w')

    f.write("# Volume #{volume} (#{volName}) - Années #{scopeStart} (#{scopeStart.to_i + 1874}) à #{scopeEnd} (#{scopeEnd.to_i + 1874})\n\n")

    years.each do |year|

      page = Nokogiri::HTML(open(url(year, volume)))
      links = page.css('ol li a')

      links.each_with_index do |link, i|

        atf = ATF.new(link.text, link['href'])
        f.write(atf.build)

        if i != links.size - 1
          f.write("\n----\n\n")
        end

      end
    end
    f.close
  end
end

puts "Done!"
