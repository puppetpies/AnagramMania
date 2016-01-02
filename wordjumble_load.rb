require 'pp'
require 'getoptlong'
require 'MonetDB'
require './datalayerlight.rb'

def dbconnect
  @conn = DatalayerLight.new
  @conn.debug = false
  @conn.hostname = "172.17.0.6"
  @conn.username = "monetdb"
  @conn.password = "monetdb"
  @conn.dbname = "anagrams"
  @conn.autocommit = true
  begin
    @conn.connect
  rescue Errno::ECONNREFUSED
    puts "Database not running!"
    puts "Bye!"
    exit
  end
end

def query_handler(sql)
  begin
    res = @conn.query(sql)
    return res
  rescue Errno::EPIPE
    puts "Connection gone away ?" if @debug == true
  end
end

def dbclose
  if @conn.autocommit == false; @conn.commit; end
  @conn.save
  @conn.release
  @conn.close
end

def load!(num)
  dbconnect
  res = query_handler("SELECT word FROM \"anagrams\".words WHERE LENGTH(word) = #{num};")
  while row = res.fetch_hash do
    realword = row["word"]
    3.upto(realword.size) {|rsize|
      puts "Word: #{realword} Numchars: #{rsize} Word Size: #{realword.size}"
      puts "CMD: ruby wordjumble.rb -w #{realword} --numchars #{rsize} --permutations 500 -s --passes 5"
      pp %x[ruby wordjumble.rb -w #{realword} --numchars #{rsize} --permutations 500 -s --passes 5]
    }
  end
  dbclose
end

3.upto(5) {|n|
  load!(n)
}
