require 'rubygems'
require 'sinatra'
 
set :env,  :production
disable :run

require 'shrankit'

run Sinatra.application
