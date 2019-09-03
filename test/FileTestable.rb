##
# Mock File to not destroy the fs
class FileTestable
    # hexdump -v -e '"\\" "zx" 1/1 "%02X"' testpak.pak | sed -e "s/z/\\\/g"
    @@file_contents = "\x50\x41\x43\x4B\x19\x00\x00\x00\x40\x00\x00\x00\x48\x65\x6C\x6C\x6F\x20\x57\x6F\x72\x6C\x64\x21\x0A\x74\x65\x73\x74\x2E\x74\x78\x74\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x0C\x00\x00\x00\x0D\x00\x00\x00"
    @@last_write = ""
    
  # So that I can steal the contents elsewhere too without messing up seek head
  def self.file_contents
    @@file_contents
  end

  def self.last_write
    @@last_write
  end

  def self.open(path, mode)
    FileTestable.new
  end

  def self.rename(from, to)
  end

  def self.dirname(dir)
    File.dirname(dir)
  end

  def initialize
    @seek_head = 0
    @buffer = ""
  end

  def read(len = -1)
    res = ""
    if len == -1
      res = @@file_contents[@seek_head..len]
      @seek_head = @@file_contents.length
    else
      res = @@file_contents[@seek_head...@seek_head+len]
      @seek_head = @seek_head+len
    end
    res
  end

  def seek(to)
    @seek_head = to
  end

  def write(bytes)
    if @seek_head > @buffer.length
      missing_bytes = (@seek_head - @buffer.length)
      missing_bytes.times do
        @buffer += "\x00"
      end
      @buffer += bytes
    else
      @buffer[@seek_head, bytes.length] = bytes
    end
    @seek_head += bytes.length
    @buffer
  end

  def close
    @@last_write = @buffer
  end

  def pos
    @seek_head
  end
end

