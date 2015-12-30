########################################################################
#
# Author: Brian Hood
#
# Description: Anagrams / Permutations
#
# Application: wordjumble.rb
#
# Generate Wordjumbles and generate queries to see if the word exists
# via the Oxford English dictionary.
#
########################################################################

require 'pp'
require 'getoptlong'
require 'MonetDB'
require './datalayerlight.rb'

@debug = true

ARGV[0] = "--help" if ARGV[0] == nil

opts = GetoptLong.new(
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
  [ '--word', '-w', GetoptLong::REQUIRED_ARGUMENT],
  [ '--numchars', '-n', GetoptLong::REQUIRED_ARGUMENT],
  [ '--permutations', '-p', GetoptLong::REQUIRED_ARGUMENT],
  [ '--shuffle', '-s', GetoptLong::NO_ARGUMENT],
  [ '--passes', '-c', GetoptLong::REQUIRED_ARGUMENT]
)

opts.each do |opt, arg|
  case opt
    when '--help'
      helper = "\e[1;34mWelcome to Wordjumble\e[0m\ \n"
      helper << "\e[1;34m=====================\e[0m\ \n"
      helper << %q[
-h, --help:
   show help
-w, --word:
   dictionary word
-p, --permutations:
   number of permutations
-n, --numchars:
   width to count upto regarding given word.
-s, --shuffle:
   shuffle / randomize dictionary word character order
    i.e catapult = clttauap
-c, --passes:
   count of number of passes for single word
    
Example:
      
      ruby wordjumble.rb -w astromonical  --numchars 12 --permutations 300 -s --passes 5
      
      ]
      puts helper
      exit
    when '--word'
      @word = arg
    when '--permutations'
      @permutations = arg.to_i
    when '--numchars'
      @numchars = arg.to_i
    when '--shuffle'
      @shuffle = arg
    when '--passes'
      @passes = arg.to_i
  end
end

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

def dbclose
  if @conn.autocommit == false; @conn.commit; end
  @conn.save
  @conn.release
  @conn.close
end

def words(text, leftpos, num)
  right = num
  name = String.new
  0.upto(text.size - 2) {|n|
    name = text[leftpos...right] if text[leftpos...right].size == num
    right += 1
  }
  return name
end

def wordjumble(myword, numchars)
  wordjumble = Array.new
  word = myword
  0.upto(word.size - 3) {|n|
    w = words(word, n, numchars)
    0.upto(@permutations) {
      k = w.split(//).shuffle.join
      wordjumble.insert(0, "#{k}")
    }
  }
  wordjumble.uniq!
  idx = wordjumble.index("")
  begin
    wordjumble.delete_at(idx)
  rescue TypeError
    puts "No index to delete" if @debug == true
  end
  return wordjumble
end

def lookup(myword, numchars)
  @fulllist = Array.new
  dbconnect
  if instance_variable_defined?("@shuffle")
    myword = myword.split(//).shuffle.join
    puts "Shuffled word: #{myword}"
  end
  words = wordjumble(myword, numchars)
  inquery = "IN ("
  words.each {|n| inquery << "'#{n}', " }
  inquery.sub!(%r=, $=, "")
  inquery << ");"
  sql = "SELECT word FROM \"anagrams\".words WHERE word #{inquery}";
  begin
    res = @conn.query(sql)
  rescue Errno::EPIPE
    puts "Connection gone away ?" if @debug == true
  end
  puts sql if @debug == true
  while row = res.fetch_hash do
    puts "Word: #{row["word"]}"
    realword = row["word"]
    @fulllist.insert(0, "#{realword}")
  end
  @fulllist.sort!.uniq!
  dbclose
end

0.upto(@passes) {|p|
  puts "Pass number: #{p}"
  3.upto(@numchars) {|n|
    puts "Matches #{n} Letters"
    lookup(@word, n)
  }
}

at_exit {
  print "Results: "
  @fulllist.each {|n|
    print "#{n} "
  }
  puts "\nTotal words: #{@fulllist.size}"
}
