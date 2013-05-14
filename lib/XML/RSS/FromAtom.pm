########################################################################
#  
#    XML::RSS::FromAtom
#
#    Copyright 2005, Marcus Thiesen (marcus@thiesen.org)  All rights reserved.
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of either:
#
#    a) the GNU General Public License as published by the Free Software
#    Foundation; either version 1, or (at your option) any later
#       version, or
#
#    b) the "Artistic License" which comes with Perl.
#
#    On Debian GNU/Linux systems, the complete text of the GNU General
#    Public License can be found in `/usr/share/common-licenses/GPL' and
#    the Artistic Licence in `/usr/share/common-licenses/Artistic'.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
#
########################################################################

package XML::RSS::FromAtom;

use common::sense;

use DateTime;
use DateTime::Format::ISO8601;
use DateTime::Format::Mail;

use Moo;

use Try::Tiny;

use XML::Atom::Syndication::Feed;
use XML::RSS;

# Version set by dist.ini; do not change here.
# VERSION

has 'syndicator' => ( 
    is => 'ro',
    lazy => 1,
    builder => 'build_syndicator' );

sub build_syndicator {
    my $self = shift;
    return XML::Atom::Syndication::Feed->new(\$self->content);
}

has 'rss_processor' => (
    is => 'ro',
    lazy => 1,
    builder => 'build_rss_processor',
    handles => [qw(add_item channel)] );

sub build_rss_processor {
    return XML::RSS->new(version => '2.0');
}

has 'content' => (
    is => 'rw'
);

sub parse {
    my $self = shift;
    my $text = shift;

    $self->content( $text );
    return $self->atom_to_rss();
}

sub atom_to_rss {
    my $self = shift;
    my $doc = $self->syndicator();

    my $feed_title       = $doc->title->body();
    my $feed_description = $doc->subtitle->body();
    my $feed_link        = $doc->link->href();

    $self->channel(title => $feed_title) if ($feed_title);
    $self->channel(description => $feed_description) if ($feed_description);
    $self->channel(link => $feed_link) if ($feed_link);

    my @entries = $doc->entries();
    for my $e (@entries) {
        my $desc = '';
        $desc = $e->summary->body();
        my $content = 
            try { $e->content->body() }
            catch { undef };
        if (defined($content)  && 
            length($content) > length($desc)) {
            $desc = $$content;
        }

        my $title = $e->title->body();

        my $mod = $e->modified();
        my $upd = $e->updated();
        my $ts = defined($mod) ? $mod : $upd;
        my $dt = DateTime::Format::ISO8601->parse_datetime( $ts );

        my $link = $e->link->href();
        my $author = $e->author->name();

        $self->add_item(
                          title => $title,
                          link  => $link,
                          description => $desc,
                          pubDate => DateTime::Format::Mail->format_datetime($dt),
                          author => $author ? $author : undef,
                          );
    }

    return $self->rss_processor;
}

# ABSTRACT: create a XML::RSS object out of an Atom feed

1;

=pod

=head1 SYNOPSIS

    require XML::RSS::FromAtom;
    use LWP::Simple;
    
    my $atom2rss = new XML::RSS::FromAtom;
    my $data = get 'http://ntess.blogspot.com/atom.xml';

    my $rss = $atom2rss->parse($data);
    #$rss->isa('XML::RSS');

    # - OR -
    require XML::Atom::Syndication;
    my $atomic = XML::Atom::Syndication->instance;
    my $doc = $atomic->get('http://www.timaoutloud.org/xml/atom.xml');

    my $rss2 = $atom2rss->atom_to_rss($doc);
    #$rss2->isa('XML::RSS');


=head1 DESCRIPTION

XML::RSS::FromAtom converts a Atom style feed into an XML::RSS object.

=head1 ATTRIBUTES

=over

=item syndicator

An instance of a class that will parse the chosen Atom feed.  By default,
this is L<XML::Atom::Syndication>, but it can be any class that exposes an
equivalent interface.

=item rss_processor

An instance of a class that will hold the converted Atom feed as RSS.  By
default, this will be L<XML::RSS>.

=item content

The Atom feed represented as a string.  This will normally be populated by a
call to the parse() method.

=back

=head1 METHODS

=over

=item new( )

Instanciates a new XML::RSS::FromAtom object

=item parse( $string ) 

Parses contents of $string as an Atom feed (using XML::Atom::Syncdication) and returns
it as an XML::RSS object.

=item atom_to_rss ( $object )

Converts an XML::Atom::Syndication::Element as returned by XML::Atom::Syndication get into
an XML::RSS object.

=item build_rss_processor ()

Provides a default implementation for the rss_processor attribute.

=item build_syndicator ()

Provides a default implementation for the syndicator attribute.

=back

=head1 AUTHOR

Marcus Thiesen, C<< <marcus@thiesen.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-xml-rss-fromatom@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=XML-RSS-FromAtom>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SEE ALSO

L<XML::RSS> L<XML::Atom::Syndication> 

=head1 COPYRIGHT & LICENSE

Copyright 2005 Marcus Thiesen, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=head1 CVS

$Id: FromAtom.pm,v 1.1 2005/03/18 17:04:44 marcus Exp $

=cut
