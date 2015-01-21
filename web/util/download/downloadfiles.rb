require "httparty"
File.open("deafult_wallpaper.png", "wb") do |f|
  f.write HTTParty.get("http://www.moviehdwallpapers.com/wp-content/uploads/2014/10/images-7.jpg").parsed_response
end
