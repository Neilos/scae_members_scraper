require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'mechanize'

LOGIN_URL = 'http://scae.com/index.php?option=com_user&view=login'

username = ARGV[0]
password = ARGV[1]

DATA_FILE = "SCAE_members_data.txt"

print "Clear previous contents of data file? (Yn): "
continue = $stdin.gets.chomp!
if continue == "n"
  puts "Procedure aborted."
  exit
end

File.open(DATA_FILE, 'w'){|f| } # clear the file of any contents and close
File.open("SCAE_members_data.txt", 'a') do |file|

  agent = Mechanize.new # set up a mechanize agent to handle all the client-server  http interractions

  puts "Logging in user: #{username}..."
  login_page = agent.get(LOGIN_URL)
  login_form = login_page.forms.select { |form| form.name == 'login' }.first
  login_form.username = username
  login_form.passwd = password
  home_page = agent.submit(login_form)
  puts "User #{username} Logged in..."

  MEMBERS_PATH = 'http://scae.com/members-directory.html?membersTask=membersDetails&membersId='
  MEMBER_NOT_FOUND = "Speciality Coffee Association of Europe (SCAE)"


  # Append the headings (with column separators)
  headers = ""
  headers << 'member id'
  headers << " | "
  headers << 'profile page'
  headers << " | "
  headers << 'name'
  headers << " | "
  headers << 'description'
  headers << " | "
  headers << 'membership category'
  headers << " | "
  headers << 'addresss'
  headers << " | "
  headers << 'telephones'
  headers << " | "
  headers << 'emails'
  headers << " | "
  headers << "\r\n"
  file.write(headers) # write headers to file

  # begin looping through members
  member_id = 0
  member_found = true
  while member_id < 5460 do
    member_id += 1
    puts "Processing member #{member_id}..."
    path = MEMBERS_PATH + member_id.to_s
    member_page = agent.get(path)
    unless member_page.title == MEMBER_NOT_FOUND
      member = ""
      # get the fields and append with column separators
      member << "#{member_id}"
      member << " | "
      member << path || ""
      member << " | "
      member << member_page.search('div.members > h1').text.strip || ""
      member << " | "
      member << member_page.search('div.members > p').text.strip || ""
      member << " | "
      member << member_page.search('div.members').text.match(/Membership Category: ([a-zA-Z ]*)/).captures[0] || ""
      member << " | "
      member << member_page.search('#address').text.gsub(/Address/,"").strip || ""
      member << " | "
      member << member_page.search('#telephone').text.gsub(/Telephone/,"").strip || ""
      member << " | "
      member << member_page.search('#email').text.gsub(/E-mail/,"").strip || ""
      member << " | "
      member << "\r\n"
      file.write(member) # append to file
    end
  end
end

puts "Processing complete!"