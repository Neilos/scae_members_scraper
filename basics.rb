require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'mechanize'

PAGE_URL = "http://en.wikipedia.org/"

page = Nokogiri::HTML(open(PAGE_URL))   

puts page.css("title")[0].text

# print image 'src's
images = page.css("img")
puts images.each{|img| puts img['src'] }

# print links filtering for those with the href "image"
links = page.css("a").select{|link| link['class'] == "image"}
links.each{|link| puts link['href'] }

# print the link tags within paragraph tags
page.css('p').css("a[class=image]").each { |a| puts a['href'] }

# print out the td in the table
rows = page.css('table tr')
rows[1..-2].each do |row|
  puts row.css('td')
  puts
end

# keep retrying
puts "Getting #{PAGE_URL}"
retries = 2
begin
  raise StandardError
rescue StandardError=>e
  puts e
  if retries > 0 
    puts "Retrying #{retries} more times"
    retries -= 1
    sleep 2
    retry
  end  
else
  sleep 3.0 + rand * 3.0
end

# test response code before processing
BAD_URL = 'http://en.wikipedia.org/wiki/Not_Main_Page/'
response = Net::HTTP.get_response(URI.parse(BAD_URL))
if response.code.match(/20\d/)
  puts "Success: #{response.code}"
  puts Nokogiri::HTML(response.body).css('title').text
else
  puts "Failure: #{response.code};"
  puts "Not a valid page;"
end