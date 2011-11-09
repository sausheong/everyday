require 'csv'
require 'mail'

def write_row(mail, csv)
  data = []
  data << mail.date
  text = mail.body ? mail.body.to_s.force_encoding("utf-8") : ""
  data << cleanup(text)
  csv << data  
end

def cleanup(text)
  text = text.gsub("/", " ")
  text = text.gsub(/[^a-zA-Z@\s]/u,'')
  text.gsub(/\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-_]+\b/,'')
end

DIR_PATH = "/Users/sausheong/Downloads/enron_mail_20110402/maildir/kean-s"
EXCLUDED_DIRS = %w(. .. deleted_items all_documents archiving calendar discussion_threads)
SENT_DIRS = %w(sent sent_items)

sent = CSV.open("sent_txt_data_enron.csv", 'w')
sent << %w(date body)
inbox = CSV.open("inbox_txt_data_enron.csv", 'w')
inbox << %w(date body)

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