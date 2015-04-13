#!/usr/bin/ruby

########################################################################
#                                                                      #
# Author: Brian Hood                                                   #
# Description: Anagrams Generator                                      #
# Email: brianh6854@googlemail.com                                     #
# Version: v0.1                                                        #
#                                                                      #
########################################################################

require "json"
require "pp"
require 'MonetDB'
require './datalayerlight.rb'

@quiet = true

class Anagrams

  attr_accessor :hostname, :username, :password, :dbname
  
  def initialize
    @hostname = "127.0.0.1"
    @username = "monetdb"
    @password = "monetdb"
    @dbname = "anagrams"
  end
  
  def perms(word, maxgenperms)
    unless @quiet == false; print "\e[1;34mWord:\e[0m\ \e[1;32m#{word}\e[0m\ \e[1;34mPermutations:\e[0m\ "; end
    #print "Word: #{word}"
    @sql = "INSERT INTO \"anagrams\".\"words\" (word, anagrams) VALUES ('#{word}', "
    b = Array.new
    l = 0
    @sql << "' "
    maxgenperms.times {|n|
      a = "#{word}".split(//).shuffle
      b[l] = a.join
      l = l + 1
    }
    c = b.uniq.sort
    c.each {|s|
      @sql << "#{s} "
    }
    @sql << "');"
    return b.uniq.sort
  end

  def show(result)
    i = 0
    result.each {|n|
      unless @quiet == false
       if i <= 5
        print "\e[1;33m#{n} "
        i = i + 1
       end
      end
    }
    print " ...\e[0m\ "
    unless @quiet == false; print "\n"; end
  end

  def dbconnect
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
  
  def readfile(name)
    self.dbconnect
    File.open("#{name}", 'r') {|t|
      t.each_line {|l|
        w = l.strip
        unless w.match("'")
          c = self.perms("#{w}", 150)
          self.show(c)
          begin
            @conn.query("#{@sql}")
            unless @quiet == false; print "\e[1;30mSQL: #{@sql[0..160]}\e[0m\ \n"; end
          rescue
            puts "DB Error"
            exit
          end
        end
      }
    }
    self.dbclose
  end

end

# Start the job
puts Time.now
t = Anagrams.new
t.readfile("wordsEn.txt")
puts Time.now
#j = JSON.generate(a)

