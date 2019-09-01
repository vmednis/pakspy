# pakspy
Tool to manipulate Quake style PAK archives.

Usage:
```
ruby pakspy.rb list <pak>
               Lists contents of a PAK file
ruby pakspy.rb dump <pak> <directory-to>
               Extracts a PAK file to a directory
ruby pakspy.rb extract <pak> <file-in-pak> <file-on-fs>
               Extracts a single file from PAK to file system
ruby pakspy.rb create <pak> <directory-from>
               Creates a PAK from a directory
ruby pakspy.rb insert <pak> <file-on-fs> <file-in-pak>
               Inserts a file in existing PAK
```

Requires ruby.
