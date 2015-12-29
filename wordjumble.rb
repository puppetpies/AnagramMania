require 'pp'
require 'getoptlong'
require 'MonetDB'
require './datalayerlight.rb'

@debug = false


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
      
      ruby wordjumble -w astromonical -n 6
      
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
  puts "#{text.size} #{num}" if @debug == true
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

@fulllist = Array.new
def lookup(myword, numchars)
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
  sql = "SELECT word, anagrams FROM \"anagrams\".words WHERE word #{inquery}";
  begin
    res = @conn.query(sql)
  rescue Errno::EPIPE
    
  end
  puts sql if @debug == true
  while row = res.fetch_hash do
    puts "Word: #{row["word"]}"
    realword = row["word"]
    @fulllist.insert(0, "#{realword}")
  end
  @fulllist.sort!.uniq!

end
#dbclose

0.upto(@passes) {|p|
  puts "Pass number: #{p}"
  3.upto(@numchars) {|n|
    puts "Matches #{n} Letters"
    lookup(@word, n)
  }
}

at_exit {
  pp @fulllist
  puts "Total words: #{@fulllist.size}"
}
