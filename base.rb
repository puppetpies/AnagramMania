########################################################################
#
# Author: Brian Hood
#
# Description: Anagrams
#
# Application: base.rb
#
# Search the Oxford English dictionary for anagrams of words
#
########################################################################


require 'rubygems' if RUBY_VERSION < "1.9"
require 'MonetDB'
require './datalayerlight.rb'
require 'sinatra/base'
require 'pp'

# Yes i monkey patched Sinatra to add a get and post method

class Sinatra::Base

  class << self

    def getpost(path, opts={}, &block)
      get(path, opts, &block)
      post(path, opts, &block)
    end

  end

end

class AnagramsWeb < Sinatra::Base

  set :server, :puma
  set :logging, :true

  def dbdefaults
    @hostname = "172.17.0.6"
    @username = "monetdb"
    @password = "monetdb"
    @dbname = "anagrams"
  end

  def dbconnect
    self.dbdefaults
    @conn = DatalayerLight.new
    @conn.hostname = @hostname
    @conn.username = @username
    @conn.password = @password
    @conn.dbname = @dbname
    @conn.autocommit = false
    begin
      @conn.connect
    rescue Errno::ECONNREFUSED
      puts "Database not running!"
      puts "Bye!"
      exit
    end
  end

  def dbclose
    if @conn.autocommit == false; @conn.commit; end
    @conn.save
    @conn.release
    @conn.close
  end
  
  configure do
    enable :session
  end

  before do
    content_type :html
  end

  set :title, "Anagrams"
  set :port, 8080
  set :bind, "0.0.0.0"

  def search(anagram)
    self.dbconnect
    @anagrams = Hash.new
    if @conn.is_connected?
			sql = "SELECT word, anagrams FROM \"anagrams\".words WHERE anagrams LIKE '% #{anagram} %'";
      res = @conn.query(sql)
      while row = res.fetch_hash do
        @anagrams.update({"#{row["word"]}" => "#{row["anagrams"]}"})
      end
      #pp @anagrams.class
      #puts @anagrams
		end
    self.dbclose
  end

  getpost '/' do
    if params[:submit] != nil
      search(params[:anagram])
    end
    erb :base
  end
  
  run!

end

AnagramsWeb.new
