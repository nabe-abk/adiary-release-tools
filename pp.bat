for /f "usebackq tokens=*" %%i in (`perl -e "use Image::Magick;my $p=$INC{'Image/Magick.pm'}; $p =~ s|/[^/]*$||; print $p"`) do @set MAGICK_PATH=%%i
@rem
pp @__tools/pp.opt -a %MAGICK_PATH%;site/lib/Image
@rem
@rem A checksum error occurs in the file with icon replaced
@rem perl -e "use Win32::Exe; $exe = Win32::Exe->new('adiary.exe'); $exe->set_single_group_icon('__tools/pp.ico'); $exe->write;"
