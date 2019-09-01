##
# Class handles Quake style PAK files
class PAKFile
  attr_reader :path, :header, :file_entries

  ##
  # Opens a pak file from +path+
  def initialize(path)
    @path = path
    @file = File.open path, "rb"

    @header = PAKHeader.new @file.read 12
    file_count = @header.size / 64

    @file_entries = Hash.new
    @file.seek @header.offset
    file_count.times do
      entry = PAKFileEntry.new @file.read 64
      @file_entries[entry.name] = entry
      puts entry.name
    end
  end

  def finalize
    @file.close
  end

  ##
  # Extracts a file +name+ from this PAKFile to +path+ on system
  def extract(name, path)
    raise ArgumentError, "No such file #{name} in this PAK." if @file_entries[name].nil?

    output_file = File.new path, "wb"

    @file.seek @file_entries[name].offset
    output_file.write @file.read @file_entries[name].size

    output_file.close
  end

  ##
  # Reperesents PAK header block
  class PAKHeader
    attr_accessor :magic, :offset, :size

    ##
    # Unpacks the 12 header bytes from +entry+
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

  ##
  # Represents PAK file entry block
  class PAKFileEntry
    attr_accessor :name, :offset, :size

    ##
    # Unpacks the 64 file entry bytes from +entry+
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
end

file = PAKFile.new ARGV[0]

file.extract(ARGV[1], ARGV[2]) if ARGV.size == 3
