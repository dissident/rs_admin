require 'sinatra'
require 'mongo'
require 'dotenv/load'

client = Mongo::Client.new(ENV['MONGO'])

collection = client['tc-exits']

get '/' do
  erb :index, layout: :main
end

get '/exits' do
  limit = 20
  offset = params[:offset].to_i || 0
  result = collection.find.skip(offset).limit(limit)
  count = collection.count
  erb :exits, layout: :main, locals: {
    exits: result, count: count, offset: offset, limit: limit }
end

get '/exits/:id' do |id|
  exit = collection.find(_id: BSON::ObjectId(id)).first
  erb :exit, layout: :main, locals: { exit: exit }
end
