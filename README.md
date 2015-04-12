# AnagramMania

Well its something i came up with when i woke up thinking about other things programming languages.

How fast can you create anagrams of the entire english dictionary of wordlist.

However the project is now evolving.

Its written in Ruby

The Database backend is MonetDB

Feel free to have play !

How to get it working
=====================

You can install MonetDB from https://www.monetdb.org/Downloads?x=101&y=12

They have all the major distro's

If your an Arch Linux fan https://aur.archlinux.org/packages/monetdb

Install package you should be good !

Create the schema

monetdbd create /path/to/myfarm
monetdbd start /path/to/myfarm
monetdb create anagrams
monetdb release anagrams

mclient -u monetdb -d anagrams # Default password same as the user.

The paste the schema anagrams.sql into the client its small contains no data.

Loading the data is just

ruby main.rb

It will take as fast as your computer is jruby does this faster from what i found.

This is all i have so far and will update regularly !

PS: Plus it give you your first exposure to MonetDB if you haven't seen it before

Have fun!
