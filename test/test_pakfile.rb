require './test/FileTestable.rb'
require 'minitest/autorun'
require 'pakspy'

class PAKFileTest < Minitest::Test
  def setup
    @pak = PAKFile.new "test.pak"
  end

  def test_class_header
    header_bin = FileTestable.file_contents[0...12]
    header = PAKFile::Header.new header_bin

    assert_equal "PACK", header.magic
    assert_equal 25, header.offset
    assert_equal 64, header.size
  end

  def test_class_file_entry
    #Hide console output
    stdout = $stdout
    $stdout = File.open File::NULL, "w"
    

    file_entry = PAKFile::FileEntry.new @pak

    assert_equal "", file_entry.name
    assert_equal "", file_entry.read

    $stdout = stdout
  end

  def test_class_file_entry_pak
    file_entry_bin = FileTestable.file_contents[25...25+64]
    file_entry = PAKFile::FileEntryPAK.new @pak, file_entry_bin

    assert_equal "test.txt", file_entry.name
    assert_equal 12, file_entry.instance_variable_get(:@offset)
    assert_equal "Hello World!\n".length, file_entry.instance_variable_get(:@size)

    assert_equal "Hello World!\n", file_entry.read
  end

  def test_class_file_entry_system
    path = "/home/vmednis/testpak.pak"
    file_entry = PAKFile::FileEntrySystem.new @pak, path, "paks/testpak.pak"

    assert_equal "paks/testpak.pak", file_entry.name
    assert_equal "/home/vmednis/testpak.pak", file_entry.instance_variable_get(:@path)
    
    assert_equal FileTestable.file_contents, file_entry.read
  end

  def test_files_list
    assert_equal ["test.txt"], @pak.send(:files_list)
  end
  
  def test_file_find
    assert_equal "test.txt", @pak.send(:file_find, "test.txt").name
  end

  def test_file_add
    path = "/home/vmednis/testpak.pak"
    file_entry = PAKFile::FileEntrySystem.new @pak, path, "paks/testpak.pak"

    @pak.send(:file_add, file_entry)
    assert_equal "paks/testpak.pak", @pak.send(:file_find, "paks/testpak.pak").name
  end

  def test_list
    assert_equal ["test.txt"], @pak.list
  end

  def test_save
    @pak.save "/home/vmednis/testpak.pak"

    # If there's only one file in a pak there's only one way to save it
    assert_equal FileTestable.file_contents, FileTestable.last_write
  end

  def test_insert
    @pak.insert "/home/vmednis/testpak.pak", "paks/testpak.pak"

    assert_equal "paks/testpak.pak", @pak.send(:file_find, "paks/testpak.pak").name
  end

  def test_extract
    @pak.extract "test.txt", "test.txt"

    assert_equal "Hello World!\n", FileTestable.last_write
  end

  def test_extract
    @pak.extract_all "."

    assert_equal "Hello World!\n", FileTestable.last_write
  end
end

