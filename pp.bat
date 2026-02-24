@rem
pp @__tools/pp.opt
@rem
@rem A checksum error occurs in the file with icon replaced
@rem perl -e "use Win32::Exe; $exe = Win32::Exe->new('adiary.exe'); $exe->set_single_group_icon('__tools/pp.ico'); $exe->write;"
