require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require 'json'
require 'base64'
require 'cgi'
require 'net/http'
require 'uri'
require 'securerandom'
require './models'

# view for debug
get '/' do
  @pictograms = Pictogram.all
  erb :index
end

post '/image_request' do
  # image sent from iOS
  image = params[:image]
  # delete indentions from Base64 sent from iOS
  image_chomp = image.gsub(/[\r\n]/,"")
  # send image to ML server
  url = '10.120.96.150:5000//estimate'
  req = Net::HTTP::Post.new('/estimate')
  # encode image from iOS to Base64
  base64_image = Base64.strict_encode64(image_chomp)
  # cgi escape Base64 sending to ML server
  escaped_image = CGI.escape(base64_image)
  req.set_form_data({'image'=>image})
  res = Net::HTTP.new('10.120.96.150','5000').start {|http| http.request(req)}
  res_body =  JSON.parse(res.body)
  label = res_body['pict_label']
  # return result to iOS
  pictogram = Pictogram.find_by(label: label)
  return_data = {"title": pictogram.title, "image": pictogram.image_url}
  return_json = JSON.pretty_generate(return_data)
  puts return_json
  return return_json
end

post '/translate' do
  # translation request from iOS
  title = params[:title]
  language = params[:language]
  language_code = Language.find_by(language: language).code

  # API credentials
  api_key = ENV['API_KEY']
  host = 'https://api.cognitive.microsofttranslator.com'
  path = '/translate?api-version=3.0'
  # translate language
  params = '&to=' + language_code

  uri = URI (host + path + params)

  content = '[{"Text" : "' + title + '"}]'

  request = Net::HTTP::Post.new(uri)
  request['Content-type'] = 'application/json'
  request['Content-length'] = content.length
  request['Ocp-Apim-Subscription-Key'] = api_key
  request['X-ClientTraceId'] = SecureRandom.uuid
  request.body = content

  response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
    http.request (request)
  end

  result = response.body.force_encoding("utf-8")

  #return result to iOS
  json = JSON.parse(result)[0]
  translated_text = json['translations'][0]["text"]
  return_result = {'text'=>translated_text}
  return_json = JSON.pretty_generate(return_result)
  puts return_json
  return return_json
end
