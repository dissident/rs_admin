require 'sinatra'
require 'mongo'
require 'dotenv/load'

client = Mongo::Client.new(ENV['MONGO'])

exits_collection = client['tc-exits']
upworks_collection = client['upworks']

use Rack::Auth::Basic do |username, password|
  username == ENV['USERNAME'] and password == ENV['PASS']
end

get '/' do
  erb :index, layout: :main
end

get '/exits' do
  limit = 20
  offset = params[:offset].to_i || 0
  result = exits_collection.find({}, sort: {value: -1}).skip(offset).limit(limit)
  count = exits_collection.count
  erb :list, layout: :main, locals: {
    entities: result, count: count, offset: offset, limit: limit, list_name: 'exits' }
end

get '/exits/:id' do |id|
  exit = exits_collection.find(_id: BSON::ObjectId(id)).first
  erb :show, layout: :main, locals: { exit: exit }
end

get '/upworks' do
  limit = 20
  offset = params[:offset].to_i || 0
  result = upworks_collection.find({}, sort: {value: -1}).skip(offset).limit(limit)
  count = upworks_collection.count
  
  countries = upworks_collection.aggregate([
    { '$match' => { 'parsed' => { '$exists' => true }}},
    { '$group' => { '_id' => '$parsed.Country'}}
  ])
  erb :list, layout: :main, locals: {
    entities: result, count: count, offset: offset, limit: limit, list_name: 'upworks' }
end

get '/upworks/:id' do |id|
  exit = upworks_collection.find(_id: BSON::ObjectId(id)).first
  erb :show, layout: :main, locals: { exit: exit }
end
