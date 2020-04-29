require "net/http"
require "uri"
require "json"

codes = [*1..9]
filename = "BLV.md"

def title(i, c=0)
  acte = "#{i['libelle'].partition(" ").first.capitalize} #{i['libelle'].split(" ")[1..-1].join(" ")}" # Title case first word
  acte = acte.gsub(" (BLV #{i['code'].to_s})", "").gsub("; BLV #{i['code'].to_s}", "") # Remove BLV references
  if i['typeElement'] == "ACTE"
    url = "https://prestations.vd.ch/pub/blv-publication/actes/consolide/#{i['code']}?id=#{i['atelierId']}"
    output = "- #{i['code']} [#{acte}](#{url})"
  else
    output = "\n#{"#" * c} #{i['code']} #{i['libelle']}"
  end
  return output
end

def output(file, i, c=1)
  file.puts title(i, c)
  if i['children'].count > 0
    c += 1
    i['children'].each do |child|
      output(file, child, c)
    end
  end
end


begin
  file = File.open(filename,'w')

  file.puts "<!-- Generated @ #{Time.now} -->"

  codes.each do |code|
    code = code.to_s
    uri = URI.parse("https://prestations.vd.ch/pub/blv-publication/api/recueil-systematique?code=#{code}")
    response = Net::HTTP.get_response(uri)
    blv = JSON.parse(response.body)

    blv.each do |vol|
      if vol['code'] == code
        output(file, vol)
      end
    end

    file.puts "\n---"

  end
rescue IOError => e
  puts "oops"
ensure
  file.close()
end

puts "Fichier enregistré sous '#{Dir.pwd}/#{filename}'"
