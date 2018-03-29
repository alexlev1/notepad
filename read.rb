require_relative 'post'
require_relative 'link'
require_relative 'task'
require_relative 'memo'

require 'optparse'

# Все наши опции будут записаны сюда
options = {}

OptionParser.new do |opt|
  opt.banner = "Usage: read.rb [options]"

  opt.on('-h', 'Prints this help') do
    puts opt
    exit
  end

  opt.on('--type POST_TYPE', 'какой тип постов показывать (по умолчанию любой') { |o| options[:type] = o }
  opt.on('--id POST_ID', 'если задан id - показываем подробно только этот пост') { |o| options[:id] = o }
  opt.on('--limit NUMBER', 'сколько последних постов показать (по умолчению все') { |o| options[:limit] = o }
end.parse!

begin
  result = if !options[:id].nil?
             Post.find_by_id(options[:limit], options[:type], options[:id])
           else
             Post.find_all(options[:limit], options[:type])
           end
rescue SQLite3::SQLException => error
  puts "Не возможно подключиться к базе данных!"
  abort error.message
end

if result.is_a? Post
  puts "Запись #{result.class.name}, id = #{options[:id]}"

  result.to_strings.each do |line|
    puts line
  end
else # покажем таблицу результатов
  print "| id\t| @type\t| @created_at\t\t\t| @text \t\t\t| @url\t\t| @due_date \t "

  result.each do |row|
    puts

    row.each do |element|
      print "| #{element.to_s.delete("\\n\\r")[0..40]}\t"
    end
  end
end

puts