
feeling = ""

#while !feeling.match(/(good|bad)/i)
#  puts "How are you doing today? (good or bad)"
#  feeling = gets.chomp
#end
#
#if feeling == "good"
#  puts "Awesome! Keep on keepin' on!"
#else
#  puts "I'm sorry to hear that"
#end
#

loop {
  puts "How are you doing today? (good or bad)"
  feeling = gets.chomp
  break if feeling.match(/(good|bad)/i)
}

feeling == "good" ? puts("Awesome! Keep on keepin' on!") : puts("I'm sorry to hear that")
