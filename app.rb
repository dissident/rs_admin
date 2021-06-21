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
  result = exits_collection.find({}, sort: {created_at: -1}).skip(offset).limit(limit)
  count = exits_collection.count
  erb :list, layout: :main, locals: {
    entities: result,
    count: count,
    offset: offset,
    limit: limit,
    list_name: 'exits',
    filters: {}
  }
end

get '/exits/:id' do |id|
  exit = exits_collection.find(_id: BSON::ObjectId(id)).first
  erb :show, layout: :main, locals: { exit: exit }
end

get '/upworks' do
  limit = 20
  offset = params[:offset].to_i || 0

  filter = {}

  filter["parsed.#{params[:budget]}"] = { '$exists' => true } if params[:budget]
  pp params[:budget_more]
  filter["parsed.Budget.value"] = { '$gt' => params[:budget_more].to_i } if params[:budget_more]
  filter["parsed.Hourly Range.to"] = { '$gt' => params[:hourly_range_more].to_i } if params[:hourly_range_more]
  filter['parsed.Country'] = params[:countries] if params[:countries]

  result = upworks_collection.find(filter, sort: {created_at: -1}).skip(offset).limit(limit)
  count = upworks_collection.find(filter).count
  
  countries = upworks_collection.aggregate([
    { '$match' => { 'parsed' => { '$exists' => true }}},
    { '$group' => { '_id' => '$parsed.Country'}}
  ])
  budget = [{'_id' => 'Budget'}, {'_id' => 'Hourly Range'}]
  budget_more = [{'_id' => 999 }, {'_id' => 1999 }, {'_id' => 2999 }]
  hourly_range_more = [{'_id' => 19 }, {'_id' => 29 }, {'_id' => 39 }, {'_id' => 49 }, {'_id' => 59 }]
  erb :list, layout: :main, locals: {
    entities: result,
    count: count,
    offset: offset,
    limit: limit,
    list_name: 'upworks',
    filters: { countries: countries, budget: budget, budget_more: budget_more, hourly_range_more: hourly_range_more }
  }
end

get '/upworks/:id' do |id|
  exit = upworks_collection.find(_id: BSON::ObjectId(id)).first
  erb :show, layout: :main, locals: { exit: exit }
end
