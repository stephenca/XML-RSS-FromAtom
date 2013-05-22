#!/usr/bin/env perl -T
use common::sense;
use Data::Dumper;
use File::Slurp;
use File::Spec;
use Test::Most;
use XML::RSS::FromAtom;
use XML::Atom::Syndication::Feed;

my $feed = 'headlines.atom';

my $content = read_file(File::Spec->catfile('t', $feed));

my $fd;
lives_ok {
    $fd = XML::Atom::Syndication::Feed->new(\$content );
} 
'Create Feed ok';

my $rss2atom;
lives_ok {
    $rss2atom = XML::RSS::FromAtom->new();
}
'Call to new() succeeds.';

my $rss2;
lives_ok { 
    $rss2 = $rss2atom->parse($content);
}
'Call to atom_to_rss()';

isa_ok( 
    $rss2,
    'XML::RSS' );

my $title = $rss2->channel('title');

is( 
    $title,
    'The Register - Data Centre: Servers',
    'Retrieve expected feed title');

my $items = $rss2->{items};

is( 
    @{$items},
    50,
    'Retrieve expected number of items');

my $exp = { 
          'link' => 'http://go.theregister.com/feed/www.theregister.co.uk/2013/02/19/tilera_tile_gx72_processor/',   
          'author' => 'Timothy Prickett Morgan',
          'title' => 'Tilera etches \'*ss-kicking\' 72-core system-on-chip for network gear',
          'pubDate' => 'Tue, 19 Feb 2013 14:03:43 -0000',
          'description' => "<h4>Current Tile-Gx Plan B fits market needs better than Plan A</h4> <p>It is not just difficult to design and manufacture a chip for workloads that will be run many years in the future, it is damned near impossible. This is because so many shifting alternative technologies will materialize between the time you make your plan and when it is executed. Any chipmaker has to be both flexible and patient - an equally difficult feat for both upstart processor vendors and incumbents. Tilera, still very much in startup mode nine years after its founding, is getting traction with its many-cored Tile-Gx system-on-chips and is rolling out a new model with 72 cores on a single die.\x{2026}</p>"
        };

is_deeply(
    $items->[-1],
    $exp,
    'Item as expected.');

done_testing;
