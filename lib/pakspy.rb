
if ENV["RUNNING_TESTS"].nil?
  class FileTestable < File
  end
end

##
# Class handles Quake style PAK files
class PAKFile
  ##
  # Opens an existing PAK file at +path+ or if not specified creates a virtual PAK
  def initialize(path = nil)
    @file_hash = Hash.new
    @pak_file = nil

    unless path.nil?
      @pak_file = FileTestable.open path, "rb"

      header = Header.new @pak_file.read 12
      puts "Warning: Might not be a real PAK" unless header.magic == "PACK"
      file_count = header.size / 64

      @pak_file.seek header.offset
      file_count.times do
        entry = FileEntryPAK.new self, @pak_file.read(64)
        file_add entry
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
    FileTestable.dirname(path).split(/[\/\\]/).each do |dir|
      path_current += dir
      Dir.mkdir path_current unless Dir.exist?(path_current)
      path_current += "/"
    end

    # Transfer contents
    file = FileTestable.open path, "wb"
    file.write file_entry.read

    file.close
  end

  ##
  # Extracts all files in PAK to +dir+ directory
  def extract_all(dir)
    files_list.each do |file_name|
      extract file_name, dir + "/" + file_name
    end
  end

  ##
  # Inserts a system file at +path+ as +name+
  def insert(path, name)
    file_add FileEntrySystem.new self, path, name
  end

  ##
  # Inserts a directory +dir+ recursively contents as their names
  def insert_all(dir)
    insert_all_helper(dir, "")
  end

  ##
  # Saves all the changes to +path+
  def save(path)
    tmp_path = "#{path}.tmp_"
    file = FileTestable.open tmp_path, "wb"
    
    file_entries = Array.new

    # Will finish header later when we know where the file entries will be
    file.write "PACK"
    file.seek 12

    # Insert all of the files
    files_list.each do |name|
      entry = file_find name

      file_entry = Hash.new
      file_entry[:name] = entry.name
      file_entry[:offset] = file.pos

      file.write entry.read

      file_entry[:size] = file.pos - file_entry[:offset]
      file_entries.push file_entry
    end

    # Now we know the rest of the info needed for the header
    file_entry_pos = file.pos
    file.seek 4
    file.write [file_entry_pos, file_entries.length * 64].pack("VV")

    # And finally add the file entries
    file.seek file_entry_pos
    file_entries.each do |file_entry|
      file.write [file_entry[:name], file_entry[:offset], file_entry[:size]].pack("a56VV")
    end
    
    # close so we can open it again
    file.close

    # And finally move it to the correct place
    FileTestable.rename tmp_path, path
  end

  ##
  # Lists all files in PAK to an array
  def list
    files_list
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
    @file_hash.values.map { |entry| entry.name }
  end

  def insert_all_helper(dir, prefix)
    Dir.entries(dir).each do |entry|
      unless entry == "." or entry == ".."
        if FileTestable.directory? "#{dir}/#{entry}"
          insert_all_helper("#{dir}/#{entry}", "#{prefix}#{entry}/")
        else
          insert("#{dir}/#{entry}", "#{prefix}#{entry}")
        end
      end
    end
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
      f = FileTestable.open @path, "rb"
      data = f.read
      f.close
      data
    end
  end
end

