require 'uri'
require 'net/http'
require 'date'
require 'json'

if ARGV.length != 1
    puts "Usage: ruby powerball.rb <base_directory>"
    exit
end

Dir.chdir ARGV.first

url = URI("https://www.calottery.com/sitecore/content/Miscellaneous/download-numbers/?GameName=powerball&Order=No")

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

request = Net::HTTP::Get.new(url)
request["cookie"] = 'website%23sc_wede=1; BNES_website%23sc_wede=jK35WmRnfsn19RQC4Rv%2FGbX41aI8DjiniYQQ3QqxJMllPSYZXZU%2BVRALYbXpKNHf'

response = http.request(request)

lines = response.read_body.split("\r\n").drop(5).map do |line| 
    row = line.split(/\s\s+/)
    {
        draw_number: row.first,
        draw_date: Date.parse(row[1]),
        balls: row.slice(2, 6),
        powerball: row.last
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
    lottery: 'Powerball'
}
write_file('summary.json', summary)



