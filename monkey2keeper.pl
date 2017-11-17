#!/usr/bin/env perl
use Text::CSV;

@ARGV == 2 or die "error: <monkeybox_csv> <client_name>\n\n";

my $folder_root = $ARGV[1];
$folder_root =~ s/\s+/-/g;

open(CSV, "<$ARGV[0]") or die "error: unable to read $ARGV[0]\n\n";

my $csv = Text::CSV->new ({ binary => 1 });

my $row = $csv->getline(CSV);
my @th = @$row;

while($row = $csv->getline(CSV)) {

  my @td = @$row;

  $folder = $folder_root;
  my @search = grep { /^top secret$/ } @td;
  @search && do { $folder .= "__TOPSECRET"; };

  my %hash = ();
  my @fcols = ($folder,'','','','','','');
  for(my $i=0; $i < @th; $i++) {
    if($th[$i] =~ /^title$/i)                { $fcols[1] = "\"$td[$i]\""; }
    elsif($th[$i] =~ /^username_or_email$/i) { $fcols[2] = "\"$td[$i]\""; }
    elsif($th[$i] =~ /^password$/i)          { $fcols[3] = "\"$td[$i]\""; }
    elsif($th[$i] =~ /^url$/i)               { $fcols[4] = "\"$td[$i]\""; }
    elsif($th[$i] =~ /^notes$/i)             { $fcols[5] = "\"$td[$i]\""; }
    else {
        if($td[$i] !~ /^\".*\"$/) { $td[$i] = "\"$td[$i]\""; }
        $hash{$th[$i]} = $td[$i];
    }
  }

  my @ccols = ();
  foreach my $key (sort {$a cmp $b} keys %hash) {
      push @ccols, $key, $hash{$key};
      if($key eq "device_name" && $hash{$key} ne "") {
        my $title = $hash{$key}." ".$fcols[1];
        $title=~s/\"//g;
        $fcols[1] = "\"$title\"";
      }
  }

  printf("%s\n", join ",", @fcols, @ccols);

}

close(CSV)
