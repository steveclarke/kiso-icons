say "Use vendor/icons for pinned icon sets"
empty_directory "vendor/icons"
keep_file "vendor/icons"

say "Copying binstub"
copy_file "#{__dir__}/bin/kiso-icons", "bin/kiso-icons"
chmod "bin", 0755 & ~File.umask, verbose: false
