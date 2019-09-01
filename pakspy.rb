class PAKHeader
  attr_accessor :magic, :offset, :size

  def initialize(header)
    # magic  - 4 byte arbitary string (not null terminated)
    # offset - 4 byte integer (little endian)
    # size   - 4 byte integer (little endian)
    data = header.unpack "a4VV"

    @magic  = data[0]
    @offset = data[1]
    @size   = data[2]
  end
end

class PAKFileEntry
  attr_accessor :name, :offset, :size

  def initialize(entry)
    # name   - max 58 byte null terminated string
    # offset - 4 byte integer (little endian)
    # size   - 4 byte integer (little endian)
    
    data = entry.unpack "a56VV"

    @name   = data[0].rstrip
    @offset = data[1]
    @size   = data[2]
  end
end

file = File.open ARGV[0], "rb"
header = PAKHeader.new file.read 12
file_count = header.size / 64
puts "#{ARGV[0]} contains #{file_count} files:"

file.seek header.offset
file_count.times do 
  file_entry = PAKFileEntry.new file.read 64
  file_size_kib = (file_entry.size / 1024.0).round 2
  puts "#{file_entry.name} #{file_size_kib} KiB"
end
