use Digest::MD5;
use File::Glob;
use subs 'glob';
sub glob { return File::Glob::bsd_glob(@_); }

sub digest {
  my $file = shift;
  open(FILE, $file) or return "Can't open '$file': $!";
  binmode(FILE);    
  return Digest::MD5->new->addfile(*FILE)->hexdigest;
}

sub dofile {
  my ($file) = @_;
  my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = stat($file);
  printf "%s % 10d % 12d %s\n", digest($file), $size, $ctime, $file;
}

sub doit {
  foreach(@_) {
    if(-d $_) {
      doit(glob("$_\\*"));
    } elsif(-e $_) {
      dofile($_);
    } else {
      doit(glob($_));
    }
  }
}
doit(@ARGV);
