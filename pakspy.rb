require './PAKFile.rb'

def print_usage
  puts "Usage:"
  puts "pakspy list <pak>"
  puts "       Lists contents of a PAK file"
  puts "pakspy dump <pak> <directory-to>"
  puts "       Extracts a PAK file to a directory"
  puts "pakspy extract <pak> <file-in-pak> <file-on-fs>"
  puts "       Extracts a single file from PAK to file system"
  puts "pakspy create <pak> <directory-from>"
  puts "       Creates a PAK from a directory"
  puts "pakspy insert <pak> <file-on-fs> <file-in-pak>"
  puts "       Inserts a file in existing PAK"
end

if ARGV.length > 1
  command, *arguments = ARGV

  case command
  when "list"
    if arguments.length == 1
      pak = PAKFile.new arguments[0]
      pak.list.each do |name|
        puts name
      end
    else
      print_usage
    end
  when "dump"
    if arguments.length == 2
      pak = PAKFile.new arguments[0]
      pak.extract_all arguments[1]
    else
      print_usage
    end
  when "extract"
    if arguments.length == 3
      pak = PAKFile.new arguments[0]
      pak.extract arguments[1], arguments[2]
    else
      print_usage
    end
  when "create"
    if arguments.length == 2
      pak = PAKFile.new
      pak.insert_all arguments[1]
      pak.save arguments[0]
    else
      print_usage
    end
  when "insert"
    if arguments.length == 3
      pak = PAKFile.new arguments[0]
      pak.insert arguments[1], arguments[2]
      pak.save arguments[0]
    else
      print_usage
    end
  else
    print_usage
  end
else
  print_usage
end
