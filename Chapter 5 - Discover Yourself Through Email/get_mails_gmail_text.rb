require 'csv'
require 'mail'
require 'nokogiri'

def write_row(mail, csv)
  data = []
  data << mail.date
  text = ""
  if mail.text_part
    text = mail.text_part.to_s.force_encoding("utf-8")
  else
    html = Nokogiri::Slop(mail.body.to_s)
    text = html.text.force_encoding("utf-8")
  end  
  data << cleanup(text)
  csv << data  
end

def cleanup(text)
  text = text.gsub("/", " ")
  text = text.gsub(/[^a-zA-Z@\s]/u,'')
  text.gsub(/\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}\b/,'')
end

EMAILS_TO_RETRIEVE = 2000

USER = ''
PASS = ''
Mail.defaults do
  retriever_method :imap, :address => "imap.gmail.com",
                          :port       => 993,
                          :user_name  => USER,
                          :password   => PASS,
                          :enable_ssl => true
end

{:inbox => 'INBOX', :sent => '[Gmail]/Sent Mail'}.each do |name, mailbox|
  emails = Mail.find(:mailbox => mailbox, 
                     :what => :last, 
                     :count => EMAILS_TO_RETRIEVE, 
                     :order => :dsc)

  CSV.open("#{name}_txt_data_gmail.csv", 'w') do |csv|
    csv << %w(date body)
    emails.each do |mail|
      begin         
        write_row mail, csv
      rescue
        puts "Cannot write this mail -> #{mail.from} to #{mail.to} with subject: #{mail.subject}"
        puts $!
      end
    end
  end
end
