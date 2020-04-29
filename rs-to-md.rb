require "rubygems"
require "nokogiri"
require "open-uri"

files = ['RS', 'RS-Int']

def scrape(i)
  url = "https://www.admin.ch/opc/fr/classified-compilation/#{i}.html"
  return Nokogiri::HTML(open(url))
end

def title(doc)
  return doc.at_css('#content h1').text.gsub(/\s+/, " ").strip
end

def process(filename)
  begin
    scope = [*1..9]

    f = File.open("#{filename}.md","w")
    f.puts "<!-- Generated @ #{Time.now} -->"

    scope.each do |i|
      begin
        if filename == 'RS-Int'
          i = "0.#{i}"
        end
        subscope = [*0..9]
        doc = scrape(i)
        f.puts "\n# #{title(doc)}"
        puts "'#{title(doc)}' en traitement..."
        subscope.each_with_index do |ii|
          begin
            nb = "#{i}#{ii}"
            doc = scrape(nb)
            f.puts "\n## #{title(doc)}"

            table = doc.at_css("#content table")
            rows = table.css("tr")

            # Start loop for each row
            rows.each do |row|

              # Sanitize string
              string = row.text.gsub(/\s+/, " ").strip

              if row.at_css("h2") # If it's a subheading, add relevant markdown tag
                f.puts "\n### #{string}"
              elsif row.at_css("h3")
                f.puts "\n#### #{string}"
              else # If it ain't a title, then
                isLaw = false
                link = ''
                links = row.css('a')
                links.each do |a|
                  unless a['href'].nil? || !a['href'].include?("index.html")
                    isLaw = true
                    link = a['href']
                  end
                end
                if isLaw
                  strRs = row.css('td')[0].text.gsub(/\s+/, " ").strip
                  strLaw = row.css('td')[1].text.gsub(/\s+/, " ").strip
                  string = strRs + " [" + strLaw + "](https://www.admin.ch" + link + ")"
                  unless string.length < 2
                    f.puts "- #{string}"
                  end
                else
                  unless string.length < 2
                    f.puts "- #{string.sub(' → ', ' _→ ')}_"
                  end
                end
              end
            end

          rescue OpenURI::HTTPError => e
          end
        end
      rescue OpenURI::HTTPError => e
      end
      f.puts "\n---"
    end
  rescue IOError => e
    puts "Oops !"
  ensure
    f.close()
    puts "Fichier enregistré sous '#{Dir.pwd}/#{filename}'"
  end
end

files.each do |f|
  process(f)
end
