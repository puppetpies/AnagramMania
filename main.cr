#!/usr/bin/ruby

########################################################################
#                                                                      #
# Author: Brian Hood                                                   #
# Description: Anagrams Generator                                      #
# Email: brianh6854@googlemail.com                                     #
# Version: v0.1                                                        #
#                                                                      #
########################################################################

# Crystal version using crystal-monetdb-libmapi
#
# You will need todo shards update or crystal deps before you compile
#
# To build
#
# crystal build main.cr
# ./main

require "./crystal-monetdb-libmapi/monetdb"
require "./crystal-monetdb-libmapi/monetdb_data"

class Anagrams

  property? mid : MonetDBMAPI::Mapi
  getter host, username, password, db, mid, conn
  setter host, username, password, db, mid, conn, quiet
  
  def initialize
    @host = "172.17.0.7"
    @port = 50000
    @username = "monetdb"
    @password = "monetdb"
    @db = "anagrams"
    @quiet = true
    @conn = MonetDB::ClientJSON.new
    @conn.host = @host
    @conn.port = @port
    @conn.username = @username
    @conn.password = @password
    @conn.db = @db
    @mid = @conn.connect
    @conn.setAutocommit(@mid, true)
  end
  
  def perms(word, maxgenperms)
    unless @quiet == false; print "\e[1;34mWord:\e[0m\ \e[1;32m#{word}\e[0m\ \e[1;34mPermutations:\e[0m\ "; end
    #print "Word: #{word}"
    @sql = "INSERT INTO \"anagrams\".\"words\" (word, anagrams) VALUES ('#{word}', "
    b = Hash(Int32, String).new
    l = 0_i32
    @sql = "#{@sql}' "
    maxgenperms.times {|n|
      a = "#{word}".split(//).shuffle
      #puts a
      b.merge!({l => a.join})
      l += 1
    }
    b.each { |s, x|
      @sql = "#{@sql}#{x} "
    }
    @sql = "#{@sql}');"
    #puts "SQL: #{@sql}"
    return b
  end

  def show(result)
    i = 0
    result.each {|n, x|
      unless @quiet == false
       if i <= 5
        print "\e[1;33m#{x} "
        i = i + 1
       end
      end
    }
    print " ...\e[0m\ "
    unless @quiet == false; print "\n"; end
  end
  
  def dbclose
    @conn.destroy(@mid)
  end
  
  def readfile(name)
    begin
      #dbconnect
      File.open("#{name}") {|t|
        t.each_line {|l|
          w = l.strip
          #puts w
          unless Regex.new(w) =~ "'"
            c = self.perms("#{w}", 150)
            #puts c
            #self.show(c)
            begin
              @conn.query(@mid, "#{@sql}")
              unless @quiet == false; print "\e[1;30mSQL: #{@sql}\e[0m\ \n"; end
            rescue
              puts "DB Error"
              exit
            end
          end
        }
      }
    @conn.query(@mid, "COMMIT;")
    #rescue Errno::EBADF
    #  puts "Stopping import"
    #  puts "Bye!"
    end
    self.dbclose
  end

end

# Start the job
puts Time.now
t = Anagrams.new
t.quiet = false
t.readfile("wordsEn.txt")
puts Time.now


