##
# Class handles Quake style PAK files
class PAKFile
  ##
  # Opens an existing PAK file at +path+ or if not specified creates a virtual PAK
  def initialize(path = nil)
    @file_hash = Hash.new
    @pak_file = nil

    unless path.nil?
      @pak_file = File.open path, "rb"

      header = Header.new @pak_file.read 12
      file_count = header.size / 64

      @pak_file.seek header.offset
      file_count.times do
        entry = FileEntryPAK.new self, @pak_file.read(64)
        file_add entry
        p entry.name
      end
    end
  end

  def finalize
    @pak_file.close unless @pak_file.nil?
  end

  ##
  # Extracts a file +name+ from this PAKFile to +path+ on system
  def extract(name, path)
    file_entry = file_find(name)
    raise ArgumentError, "No such file #{name} in this PAK." if file_entry.nil?
    
    # Create the necessary directories
    path_current = ""
    File.dirname(path).split(/[\/\\]/).each do |dir|
      path_current += dir
      Dir.mkdir path_current unless Dir.exists?(path_current)
      path_current += "/"
    end

    # Transfer contents
    file = File.open path, "wb"
    file.write file_entry.read

    file.close
  end

  attr_reader :pak_file

  private
  
  ##
  # Adds +file_entry+ to pak
  def file_add(file_entry)
    @file_hash[file_entry.name] = file_entry
  end
  
  ##
  # Finds file called +name+ in pak
  def file_find(name)
    @file_hash[name]
  end

  ##
  # Returns a list of all the files as an array of strings
  def files_list
    @file_hash.values
  end

  ##
  # Reperesents PAK header block
  class Header
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
  # Base class for all files handled by PAKFile
  class FileEntry
    attr_accessor :name

    ##
    # +pack+ has to be PAKFile that owns this entry
    def initialize(pack)
      @pack = pack
      @name = ""
    end

    def read
      puts "This is just a base class..."
      ""
    end
  end

  ##
  # File located inside the PAK itself
  class FileEntryPAK < FileEntry
    def initialize(pack, entry)
      super pack

      # name   - max 58 byte null terminated string
      # offset - 4 byte integer (little endian)
      # size   - 4 byte integer (little endian)
      data = entry.unpack "a56VV"

      @name   = data[0].rstrip
      @offset = data[1]
      @size   = data[2]
    end

    def read
      @pack.pak_file.seek @offset
      @pack.pak_file.read @size
    end
  end

  ##
  # File located on a file system, not in the pack
  class FileEntrySystem < FileEntry
    def initialize(pack, path, name)
      super pack
      @path = path
      @name = name
    end

    def read
      f = File.open @path, "rb"
      data = f.read
      f.close
      data
    end
  end
end

file = PAKFile.new ARGV[0]
file.extract("sound/weapons/guncock.wav", "sound/weapons/guncock.wav")

