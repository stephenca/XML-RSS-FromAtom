
use strict;
use warnings;

use 5.006;

use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "create a XML::RSS object out of an Atom feed",
  "AUTHOR" => "Stephen Cardie <stephenca\@ls26.net>",
  "BUILD_REQUIRES" => {
    "Data::Dumper" => 0,
    "File::Find" => 0,
    "File::Slurp" => 0,
    "File::Spec" => 0,
    "File::Temp" => 0,
    "Test::More" => 0,
    "Test::Most" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "XML-RSS-FromAtom",
  "EXE_FILES" => [],
  "LICENSE" => "perl",
  "NAME" => "XML::RSS::FromAtom",
  "PREREQ_PM" => {
    "DateTime" => 0,
    "DateTime::Format::ISO8601" => 0,
    "DateTime::Format::Mail" => 0,
    "Moo" => 0,
    "Try::Tiny" => 0,
    "XML::Atom::Syndication::Feed" => 0,
    "XML::RSS" => 0,
    "common::sense" => 0
  },
  "VERSION" => "0.02_01",
  "test" => {
    "TESTS" => "t/*.t t/lib/xml/rss/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



