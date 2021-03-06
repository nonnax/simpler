#!/usr/bin/env ruby
# Id$ nonnax 2022-05-09 01:44:48 +0800
require_relative 'lib/simpler'
require 'json'

use Rack::Session::Cookie, secret: SecureRandom.hex(64)

A=
Simpler.new do
  res.headers['Content-type']='text/html'

  get '/' do
    res.write 'hi '+String(session[:name])
  end

  post '/' do
    res.write 'ho'
  end

  get '/greet', name: 'simpler' do |name|
    res.headers['Content-type']='application/json'
    data = {message: 'hello, '+String(name)}
    session[:name]=name
    res.write data.to_json
  end

  get '/hi/:name', surname:'even' do |name, surname|
    res.headers['Content-type']='application/json'
    data = {message: 'hello, '+String(name)+String(surname)}
    session[:name]=name
    res.write data.to_json
  end

  get '/r' do
    res.redirect '/hello'
  end

  default do # when no match found
    res.write 'no mo'
  end

end

run A
