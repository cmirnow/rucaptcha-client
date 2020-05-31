# frozen_string_literal: true

require 'open-uri'
require 'nokogiri'

class Rucaptcha
  # Enter here your key to API rucaptcha.com
  APIKEY = '7a15763197586ddfdca673bb4d54b106'
  # Enter here url page with recaptcha
  URL_RECAPTCHA = 'https://www.google.com/recaptcha/api2/demo'

  def self.first_request
    # Request to API recaptcha.com and getting ID
    target = 'https://rucaptcha.com/in.php'
    params = {
      key: APIKEY,
      method: 'userrecaptcha',
      googlekey: data_sitekey,
      pageurl: URL_RECAPTCHA
    }
    puts 'Request to API ' + target + '...'
    puts 'Getting Request ID...'
    request(target, params)
  end

  def self.data_sitekey
    # Parsing url and getting a data-sitekey of recaptcha
    url = URL_RECAPTCHA
    html = open(url)
    puts 'Parsing ' + URL_RECAPTCHA + '...'
    doc = Nokogiri::HTML(html)
    puts 'Getting a data-sitekey...'
    doc.xpath('//@data-sitekey')
  end

  def self.request(target, params)
    # Collecting an API request
    uri = URI.parse(target)
    uri.query = URI.encode_www_form(params)
    uri.open.read
  end

  def self.second_request
    answer = first_request
    puts 'Server response: ' + answer

    if answer.include? 'OK'
      target = 'https://rucaptcha.com/res.php'
      params = {
        key: APIKEY,
        action: 'get',
        id: answer.gsub('OK|', '')
      }

      puts 'Request to API ' + target + '...'
      # Request decision result
      1.times do
        begin
          puts 'Timeout 10 seconds'
          sleep 10
          request = request(target, params)
          puts 'Server response: ' + request
          # If the captcha is not resolved, pause and make a request again
          raise unless request.include? 'OK'
        rescue StandardError
          retry
        end
      end
    end
  end
end

Rucaptcha.second_request
