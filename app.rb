require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require 'json'
require 'base64'
require 'net/http'
require 'uri'
require './models'

get '/' do
  @pictograms = Pictogram.all
  erb :index
end

post '/image_request' do
  # image sent from iOS
  image = params[:image]
  # send image to ML server
  # url = URI.parse('172.16.144.2:5000/estimate')
  url = '192.168.2.100:5000/estimate'
  req = Net::HTTP::Post.new('/estimate')
  base64_image = Base64.encode64(File.open('./public/images/fire_exit.jpg','rb').read)
  req.set_form_data({'image'=>base64_image})
  res = Net::HTTP.new('192.168.2.100','5000').start {|http| http.request(req)}
  res_body =  JSON.parse(res.body)
  label = res_body['pict_label']
  # return result to iOS
  pictogram = Pictogram.find_by(label: label)
  return_data = {"title": pictogram.title, "image": pictogram.image_url}
  return_json = JSON.pretty_generate(return_data)
  puts return_json
end

post '/test_request' do
  puts params[:image]
  return 'request reached'
end