# frozen_string_literal: true

require 'open-uri'
require 'nokogiri'

class Rucaptcha
  def self.apikey
    # Enter here your key to API rucaptcha.com
    '*******************************'
  end

  def self.first_request
    # Request to API recaptcha.com and getting ID
    target = 'https://rucaptcha.com/in.php'
    params = {
      key: apikey,
      method: 'userrecaptcha',
      googlekey: data_sitekey,
      pageurl: url_recaptcha
    }
    puts 'Request to API ' + target + '...'
    puts 'Getting Request ID...'
    request(target, params)
  end

  def self.data_sitekey
    # Parsing url and getting a data-sitekey of recaptcha
    url = url_recaptcha
    html = open(url)
    puts 'Parsing ' + url_recaptcha + '...'
    doc = Nokogiri::HTML(html)
    puts 'Getting a data-sitekey...'
    doc.xpath('//@data-sitekey')
  end

  def self.url_recaptcha
    # Enter here url page with recaptcha
    'https://www.google.com/recaptcha/api2/demo'
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
        key: apikey,
        action: 'get',
        id: answer.gsub('OK|', '')
      }

      puts 'Request to API ' + target + '...'
      # Request decision result
      1.times do |_i|
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
