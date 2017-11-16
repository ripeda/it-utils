#!/usr/bin/env perl

print("$0\n");

# batch scale image files 
# standard naming convention for scaled
# use with JS library for loading retina images after rendering page for speed
# uses sips 

use warnings;
use strict;
use Env;
use Cwd;
use File::Copy qw /copy/;
use List::Util qw /min max/;

&scandir(".");


sub scandir {
  my ($dirname) = @_;

  opendir(DIR, $dirname) or return;
  my @files = grep { -f "$dirname/$_"} readdir(DIR) or return;
  rewinddir(DIR);
  my @subdirs = grep { -d "$dirname/$_"} readdir(DIR) or return;
  closedir(DIR);

  foreach my $file (@files) {

    next unless $file =~ /^(.*)\.(jpg|png)$/;

    my $base = $1;
    my $ext = $2;
    my $orig = $dirname."/".$base.".".$ext;
    my $nm2x = $dirname."/".$base.'@2x.'.$ext;
    my $nm4x = $dirname."/".$base.'@4x.'.$ext;

    system("sips -Z 3200 $orig") == 0 or next;

    &copy($orig, $nm4x) or next;

    my @result = `sips -g pixelHeight -g pixelWidth $orig`;
    shift @result;
    @result == 2 or next;

    my @height = split /\s+/, $result[0];
    my @width = split /\s+/, $result[1];

    my $longedge = max($height[2],$width[2]);
    my $sz2x = int($longedge/2);
    my $sz1x = int($longedge/4);

    system("sips -Z $sz2x $orig --out $nm2x") == 0 or next;
    system("sips -Z $sz1x $orig") == 0 or next;
    print("... resized $orig to $sz1x and $sz2x\n");
  }

  foreach my $subdir (@subdirs) {
    next if $subdir =~ /^\./;
    &scandir($dirname."/".$subdir);
  }


}
