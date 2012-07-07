require 'stringio'
require 'csv'

CSV.open('heartbeat.csv', 'w') do |csv|
 csv << %w(ch1 ch2 combined)
  File.open('heartbeat.wav') do |file|
    while !file.eof?
      if file.read(4) == 'data'
        length = file.read(4).unpack('l').first
        wavedata = StringIO.new file.read(length)
        while !wavedata.eof? 
          ch1, ch2 = wavedata.read(4).unpack('ss')
          csv << [ch1, ch2,ch1.to_i+ch2.to_i]
        end
      end
    end
  end
end
