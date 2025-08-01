#!/usr/bin/perl
use 5.8.0;
use strict;
use Encode;
use Encode::Guess qw(ascii euc-jp shiftjis iso-2022-jp);
################################################################################
# release checker
################################################################################
my $perl = $ARGV[0] || "/usr/bin/perl";
my $opt  = "-I./lib -I./";

print "---Compile checker--------------------------------------------------------------\n";
#-------------------------------------------------------------------------------
{
	open(my $fh, "$perl -v|");
	my @lines = <$fh>;
	close($fh);
	if (!@lines) {
		print "$perl not found.\n";
		exit 1;
	}

	foreach(@lines) {
		if ($_ !~ /version|v5/) { next; }
		print "$_";
		last;
	}
}
#-------------------------------------------------------------------------------
{
	open(my $fh, "find plugin/ lib/ -name *.pm |");
	my @files = <$fh>;
	close($fh);

	my %load;
	foreach(sort(@files)) {
		chomp($_);
		$_ =~ s|^lib/||;
		if ($_ =~ /['"\\]/) {
			print "skip compile: $_\n";
			next;
		}
		my $base = $_ =~ /^(.*)_\d+\.pm/ ? "$1.pm" : $_;
		$load{$base} .= "require '$_';";
	}
	foreach(keys(%load)) {
		system("$perl $opt -e \"$load{$_}\"");
	}
}

################################################################################
# adiary Release checker
################################################################################
my $errors=0;
print "---Release checker--------------------------------------------------------------\n";
#-------------------------------------------------------------------------------
# Debug check
#-------------------------------------------------------------------------------
{
	open(my $fh, 'grep -ERni "debug\(|#\s*debug|print\s+STDERR" skel/ lib/ plugin/ *.cgi *.pl|');
	my @ary = <$fh>;
	close($fh);

	my $prev;
	foreach(@ary) {
		my ($file, $linenum, $line) = split(/:/, $_, 3);
		if ($file !~ /\.(?:pm|cgi|pl|html)$/) { next; }
		if ($line =~ /^\s*#/) { next; }
		if ($line =~ /{DEBUG}/) { next; }
		if ($line =~ /#\s*debug-safe|##\s*safe/) { next; }
		if ($line =~ /{Debug_mode}/) { next; }
		if ($line =~ m!^\s*<@>! && $line =~ m|<[\@\$]debug|) { next; }

		($prev ne $file) && print "## Debug error : $file\n";
		print "$linenum:$line";
		$prev = $file;
		$errors++;
	}
}
{
	open(my $fh, 'grep -ERni "alert\s*\(|//\s*debug" js/|fgrep -v ".min.js"|');
	my @ary = <$fh>;
	close($fh);

	my $prev;
	foreach(@ary) {
		my ($file, $linenum, $line) = split(/:/, $_, 3);
		if ($file !~ /\.js$/)  { next; }
		if ($line =~ m!^s*//!) { next; }
		if ($line =~ m!//\s*debug-safe!) { next; }

		($prev ne $file) && print "## Debug error : $file\n";
		print "$linenum:$line";
		$prev = $file;
		$errors++;
	}
}

#-------------------------------------------------------------------------------
# &nbsp; check
#-------------------------------------------------------------------------------
{
	open(my $fh, "grep -ERni '&nbsp;' skel/ js/*.js plugin/ theme/|");
	my @ary = <$fh>;
	close($fh);

	foreach(@ary) {
		my ($file, $linenum, $line) = split(/:/, $_, 3);
		print "## '&nbsp;' warning : $file\n";
		print "$linenum:$line";
	}
}

#-------------------------------------------------------------------------------
# CRLF check
#-------------------------------------------------------------------------------
{
	open(my $fh, "grep -rI '\r\n' skel/ js/*.js lib/ info/ plugin/ theme/|");
	my @ary = <$fh>;
	close($fh);

	my %files;
	foreach(@ary) {
		my ($file, $line) = split(/:/, $_, 2);
		if ($line =~ /\r\n/) {
			$files{$file} = 1;
		}
	}
	foreach(sort(keys(%files))) {
		print "## CRLF warning : $_\n";
	}
}

#-------------------------------------------------------------------------------
# BOM check
#-------------------------------------------------------------------------------
{
	open(my $fh, "grep -r '\xEF\xBB' skel/ js/*.js lib/ info/ plugin/|");
	my @ary = <$fh>;
	close($fh);
	foreach(@ary) {
		print "## BOM warning : $_\n";
	}
}

#-------------------------------------------------------------------------------
# 文字コードcheck
#-------------------------------------------------------------------------------
{
	open(my $fh, "find skel/ js/ lib/ info/ plugin/ theme/|");
	my @files = <$fh>;
	close($fh);

	foreach(@files) {
		chomp($_);
		if (-d $_) { next; }
		if ($_ !~ /\.(pm|html|css|info|dat|txt)$/) { next; }

		open(my $fh, $_);
		my @lines = <$fh>;
		close($fh);
		my $str  = join('', @lines);
		my $code = guess_encoding($str);
		if (!$code) { next; }	# 推定できず
		
		if (ref($code)) { $code = $code->name(); }
		if ($code eq 'utf8' || $code eq 'ascii') { next; }

		# shiftjis or utf8 / utf8 or shiftjis
		if ($code =~ /utf8/) { next; }

		print "## code error : $code $_ \n";
		$errors++;
	}
}

#-------------------------------------------------------------------------------
# CHANGES.txt check
#-------------------------------------------------------------------------------
{
	open(my $fh, "CHANGES.txt");
	my @files = <$fh>;
	close($fh);

	foreach(@files) {
		chomp($_);
		if ($_ !~ m|/xx|) { next; }

		print "## CHANGES.txt error : $_ \n";
		$errors++;
	}
}

#-------------------------------------------------------------------------------
# exit
#-------------------------------------------------------------------------------
{
	if ($errors) {
		print "\n## Total $errors errors.\n";
		exit 1;
	} else {
		print "## error not found.\n";
	}
}

#-------------------------------------------------------------------------------
# sub routine
#-------------------------------------------------------------------------------
sub get_lastmodified {
	my $st = [ stat(shift) ];
	return $st->[9];
}
sub get_date {
	my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(shift);
	$year+=1900;
	$mon++;
	return sprintf("$year/%02d/%02d %02d:%02d:%02d", $mon, $mday, $hour, $min, $sec);
}
