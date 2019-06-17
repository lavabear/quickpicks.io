require 'uri'
require 'net/http'
require 'date'
require 'json'

if ARGV.length != 1
    puts "Usage: ruby daily_4.rb <base_directory>"
    exit
end

Dir.chdir ARGV.first

url = URI("https://www.calottery.com/sitecore/content/Miscellaneous/download-numbers/?GameName=daily-4&Order=No")

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

request = Net::HTTP::Get.new(url)
request["cookie"] = 'website%23sc_wede=1; BNES_website%23sc_wede=jK35WmRnfsn19RQC4Rv%2FGbX41aI8DjiniYQQ3QqxJMllPSYZXZU%2BVRALYbXpKNHf; ASP.NET_SessionId=vqrry5ind20gawrooil4f355; platform-lang=en'

response = http.request(request)

lines = response.read_body.split("\r\n").drop(5).map do |line| 
    row = line.split(/\s\s+/)
    {
        draw_number: row.first,
        draw_date: Date.parse(row[1]),
        balls: row.slice(2..-1)
    }
end

def write_file(filename, contents) 
    File.open(filename,"w") do |f|
        f.write(contents.to_json)
    end
end

latest = lines.first(5)
write_file('latest.json', latest)

index = 1
lines.each_slice(25) do |l| 
    write_file("page-#{index}.json", l)
    index += 1
end

summary = {
    drawings: lines.count,
    last: lines.first,
    pages: index,
    lottery: 'Daily 4'
}
write_file('summary.json', summary)

