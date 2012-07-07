require 'rmagick'
require 'csv'
require 'active_support/all'
require 'rvideo'

vid = RVideo::Inspector.new(:file => "pulse.mov")
width, height = vid.width, vid.height
fps = vid.fps.to_i
duration = vid.duration/1000

if system("/opt/local/bin/ffmpeg -i pulse.mov -f image2 'frames/frame%05d.png'")
  CSV.open("data.csv","w") do |file|
    file << %w(frame intensity)
    (fps*duration).times do |n|
      img = Magick::ImageList.new("frames/frame#{sprintf("%05d",n+1)}.png")
      ch = img.channel(Magick::RedChannel)
      i = 0
      ch.each_pixel {|pix| i += pix.intensity}
      file << [n+1, i/(height*width)]
    end
  end
end