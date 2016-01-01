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

  def query_handler(sql)
    begin
      res = @conn.query(sql)
      return res
    rescue Errno::EPIPE
      puts "Connection gone away ?" if @debug == true
    end
  end

  def search(anagram)
    self.dbconnect
    @anagrams, @wordjumble = Hash.new, Hash.new
    if @conn.is_connected?
      sql = "SELECT word, anagrams FROM \"anagrams\".words WHERE anagrams LIKE '% #{anagram} %' OR word = '#{anagram}';";
      res = query_handler(sql)
      while row = res.fetch_hash do
        @anagrams.update({"#{row["word"]}" => "#{row["anagrams"]}"})
      end
      sql_wordjumble = "SELECT a.word AS jumble, b.word FROM \"anagrams\".words a JOIN \"anagrams\".wordjumble b ON (a.word_id = b.word_id) WHERE b.word = '#{anagram}';"
      res = query_handler(sql_wordjumble)
      while row = res.fetch_hash do
        @wordjumble.update({"#{row["jumble"]}" => "#{row["word"]}"})
      end
    end
    self.dbclose
  end

  getpost '/' do
    if params[:submit] != nil
      search(params[:anagram])
    end
    erb :base
  end
  
  get '/css/screen.css' do
     send_file 'css/screen.css', :type => :css
  end
  
  run!

end

AnagramsWeb.new
