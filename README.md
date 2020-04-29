# Scrapers
Scrape swiss laws and federal cases.
Word of warning: this is just a first try; there's massive room for improvement. _Caveat emptor._

## Files
- `rs-to-md.rb` = Recueil systématique fédéral (RS) → Markdown
- `bger-to-jekyll.rb` = Arrêts du Tribunal fédéral (ATF) → [Jekyll](https://jekyllrb.com)
- `bger-to-md.rb` = Arrêts du Tribunal fédéral (ATF) → Markdown
- `blv-to-md.rb` = Recueil systématique vaudois (BLV) → Markdown

## Requirements
1. Get ruby going on your system.
2. Install [Nokogiri](http://www.nokogiri.org/tutorials/installing_nokogiri.html).
3. For `bger-to-jekyll.rb`, make sure you've got [jekyll](https://jekyllrb.com) installed to render the files correctly. If you don't know what jekyll is, check it out; it's awesome.

## Markdown to .docx conversion
Use pandoc like so: `pandoc -s -o BLV.docx BLV.md`
