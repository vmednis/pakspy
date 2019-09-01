# pakspy
Tool to manipulate Quake style PAK archives.

Usage:
```
pakspy list <pak>
       Lists contents of a PAK file
pakspy dump <pak> <directory-to>
       Extracts a PAK file to a directory
pakspy extract <pak> <file-in-pak> <file-on-fs>
       Extracts a single file from PAK to file system
pakspy create <pak> <directory-from>
       Creates a PAK from a directory
pakspy insert <pak> <file-on-fs> <file-in-pak>
       Inserts a file in existing PAK
```

Requires ruby.
