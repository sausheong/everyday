require 'csv'
require 'mail'

def write_row(mail, csv)
  data = []
  data << (mail.from ? mail.from.first : "")
  data << (mail.to ? mail.to.first : "")
  data << mail.date
  csv << data  
end

DIR_PATH = "/Users/sausheong/Downloads/enron_mail_20110402/maildir/kean-s"
EXCLUDED_DIRS = %w(. .. deleted_items all_documents)
SENT_DIRS = %w(sent sent_items)

sent = CSV.open("sent_data_enron.csv", 'w')
sent << %w(from to date)
inbox = CSV.open("inbox_data_enron.csv", 'w')
inbox << %w(from to date)

Dir.foreach(DIR_PATH) do |file_name|
  file = File.absolute_path(file_name, DIR_PATH)
  if File.directory?(file) and !EXCLUDED_DIRS.include?(file_name)     
    Dir.foreach(file) do |mail_file|
      eml = File.absolute_path(mail_file, file)
      if File.file?(eml)
        mail = Mail.read eml
        begin 
          if SENT_DIRS.include?(file_name)
            write_row mail, sent
          else
            write_row mail, inbox
          end    
        rescue
          puts "Cannot write this mail -> #{mail.from} to #{mail.to} with subject: #{mail.subject}"
          puts $!
        end
      end
    end
  end
end

inbox.close
sent.close

exit