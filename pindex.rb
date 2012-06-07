%w[benchmark pp rexml/document net/http net/https].each { |x| require x }

user = ARGV[0]
pass = ARGV[1]
baseDir = ARGV[2]


baseDir += "/pinboard/"
xmlFile = baseDir+"bookmarks.xml"
bookmarksDir = baseDir+"/bookmarks/"


http = Net::HTTP.new("api.pinboard.in",443)
req = Net::HTTP::Get.new("/v1/posts/all")
http.use_ssl = true
req.basic_auth "#{user}", "#{pass}"
response = http.request(req)

puts("downloading bookmarks")
f = File.new(xmlFile,"w+")
f.puts response.body
f.close

xml = File.read(xmlFile)
  puts("parsing bookmarks")
  doc, posts = REXML::Document.new(xml), []
  doc.elements.each('posts/post') do |p|
    posts << p.attributes
   
   x = "pb-"+p.attributes["description"].gsub(/[\x00-\x20\x7e-\xff\s\W]/,"_")
   x = x[0,100]
   
   fn = bookmarksDir + x +".url"
    u = File.new(fn, "w")
    u.puts "[InternetShortcut]\nURL=%s\nHASH=%s\nTAGS=%s\nDATETIME=%s\nDESCRIPTION=%s\nEXTENDED=%s\nMETA=%s\nORIGIN=pinboard" % [p.attributes["href"],p.attributes["hash"],p.attributes["tag"],p.attributes["time"],p.attributes["description"],p.attributes["extended"],p.attributes["meta"]]
    u.close
     
  end
