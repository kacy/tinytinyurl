#tinytiny.rb
# My first Ruby/Sinatra app, a URL shortener.
# by Leah Culver (http://github.com/leah)
# forked by Kacy Fortner (http://github.com/kacy)
require 'rubygems'
require 'sinatra'
require 'sequel'
require 'erb'

# Base36 encoded
BASE = 36

configure do
  #DB = Sequel.connect(:adapter=>'mysql', :host=>'localhost', :database=>'shrankit', :user=>'root', :password=>'somepassword')
  DB = Sequel.sqlite
  DB.create_table? :tinyurls do
    primary_key :id
    String :url
    Integer :views
  end
end

get '/' do
  #Found in views/index.erb
  erb :index
end

post '/' do
  # Put the fatty URL in the database and display
  items = DB[:tinyurls]
  id = items.insert(:url => params[:url], :views => 0)
  url = request.url + id.to_s(BASE)
  
  "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">
  <html xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"en-us\" xml:lang=\"en-us\" >
    <head>
      <title>Shrank dos URLz</title>
      <meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />
      <style type=\"text/css\">
  		#title {
  			position: relative;
  			top: 200px;
  			text-align: center;
  			font-family: 'Gill Sans','Gill Sans MT',Corbel,Helvetica,'Nimbus Sans L',sans-serif;
  			font-size: 200%;
  		}
  		a, a:link, a:hover, a:visited {
  			color: #444;
  			font-size: 250%;
  		}
      </style>
    </head>
    <body>
    <div id=title>
      Your Shrank it url is: <br />
      <a href='#{url}'>#{url}</a>
    </div>"
end

get '/:tinyid' do
  # Resolve the tiny URL
  items = DB[:tinyurls]
  id = params[:tinyid].to_i(BASE)
  url = items.first(:id => id)
  views = url[:views]
  views += 1
  items.where(:id => id).update(:views => views)
  long_url = url[:url]
  if !long_url.include? "://"
    link = "http://"
    link << url[:url]
    redirect link
  else
    redirect url[:url]
  end
end

get '/:tinyid/views' do
  items = DB[:tinyurls]
  id = params[:tinyid].to_i(BASE)
  url = items.first(:id => id)
  views = url[:views]
  short_url = "http://shrankit.com/" + id.to_s(BASE)
  
  "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">
  <html xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"en-us\" xml:lang=\"en-us\" >
    <head>
      <title>Shrank dos URLz</title>
      <meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />
      <style type=\"text/css\">
  		#title {
  			position: relative;
  			top: 200px;
  			text-align: center;
  			font-family: 'Gill Sans','Gill Sans MT',Corbel,Helvetica,'Nimbus Sans L',sans-serif;
  			font-size: 200%;
  		}
  		a, a:link, a:hover, a:visited {
  			color: #444;
  			font-size: 250%;
  		}
      </style>
    </head>
    <body>
    <div id=title>
      The link has been viewed #{views} times. Awesome.<br />
      <a href='#{short_url}'>#{short_url}</a>
    </div>"
end