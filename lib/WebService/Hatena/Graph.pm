package WebService::Hatena::Graph;

use strict;
use warnings;
use Carp qw(croak);

use URI;
use JSON::Any;
use LWP::UserAgent;

our $VERSION = '0.07';

sub new {
    my ($class, %args) = @_;
    croak ('Both username and password are required.')
        if (!defined $args{username} || !defined $args{password});

    my $ua = LWP::UserAgent->new(agent => __PACKAGE__."/$VERSION");
       $ua->credentials('graph.hatena.ne.jp:80', '', @args{qw(username password)});

    return bless { ua => $ua }, $class;
}

sub ua { shift->{ua} }


# This method remains only for backward compatibility (less or equal
# version 0.04). Use post_data() method instead.
sub post {
    my ($self, %args) = @_;
    return $self->post_data(%args);
}

sub post_data {
    my ($self, %args) = @_;

    croak ('Graphname parameter must be passed in.')
        if !defined $args{graphname};

    my $res = $self->_post('http://graph.hatena.ne.jp/api/data', %args);

    croak (sprintf "%d: %s", $res->code, $res->message)
        if $res->code != 201;

    return 1;
}

sub get_data {
    my ($self, %args) = @_;

    croak ('Graphname parameter must be passed in.')
        if !defined $args{graphname};

    my $res = $self->_get('http://graph.hatena.ne.jp/api/data', (%args, type => 'json'));

    croak (sprintf "%d: %s", $res->code, $res->message)
        if $res->code != 200;

    return JSON::Any->jsonToObj($res->content);
}

sub post_config {
    my ($self, %args) = @_;

    croak ('Graphname parameter must be passed in.')
        if !defined $args{graphname};

    my $res = $self->_post('http://graph.hatena.ne.jp/api/config', %args);

    croak (sprintf "%d: %s", $res->code, $res->message)
        if $res->code != 201;

    return 1;
}

sub get_config {
    my ($self, %args) = @_;

    croak ('Graphname parameter must be passed in.')
        if !defined $args{graphname};

    my $res = $self->_get('http://graph.hatena.ne.jp/api/config', (%args, type => 'json'));

    croak (sprintf "%d: %s", $res->code, $res->message)
        if $res->code != 200;

    return JSON::Any->jsonToObj($res->content);
}

sub _get {
    my ($self, $url, %params) = @_;
    my $uri = URI->new($url);
    $uri->query_form(%params);
    return $self->ua->get($uri);
}

sub _post {
    my ($self, $url, %params) = @_;
    return $self->ua->post($url, \%params);
}

1;

__END__

=head1 NAME

WebService::Hatena::Graph - A Perl interface to Hatena::Graph API

=head1 SYNOPSIS

  use WebService::Hatena::Graph;

  my $graph = WebService::Hatena::Graph->new(
      username => $username,
      password => $password,
  );

  # set data to the specified graph
  $graph->post_data(
      graphname => $graphname,
      date      => $date,
      value     => $value,
  );

  # retrieve graph data
  my $graph_data = $graph->get_data(
      graphname  => $graphname,
      username   => $username,
  );

  # set config
  $graph->post_config(
      graphname      => $graphname,
      graphcolor     => $graphcolor,
      graphtype      => $graphtype,
      status         => $status,
      allowuser      => $allowuser,
      allowgrouplist => $allowgrouplist,
      stack          => $stack,
      reverse        => $reverse,
      formula        => $formula,
      maxy           => $maxy,
      miny           => $miny,
      showdata       => $showdata,
      nolabel        => $nolabel,
      userline       => $userline,
      userlinecolor  => $userlinecolor,
      comment        => $comment,
  );

  # retrieve config
  my $graph_config = $graph->get_config( graphname => $graphname );

=head1 DESCRIPTION

Hatena::Graph is a website which allows users to manage and share
daily activities with graphic representaion. WebService::Hatena::Graph
provides an easy way to communicate with it using its API.

=head1 METHODS

=head2 new ( I<%args> )

=over 4

  my $graph = WebService::Hatena::Graph->new(
      username => $username,
      password => $password,
  );

This method creates and returns a new WebService::Hatena::Graph
object.

Both username and password are required. If not passed in, it will
croak immediately.

=back

=head2 post_data ( I<%args> )

=over 4

  $graph->post_data(
      graphname => $graphname,
      date      => $date,
      value     => $value,
  );

This method sets I<$value> on I<$date> to the graph specified by
I<$graphname> parameter.

B<NOTE>: If the I<graphname> parameter isn't passed in or the request
ends in failure for some reason, this method will croak
immediately. Additionally, you might want to consult the official
documentation of Hatena::Graph API to know more about how you can pass
the parameters in.

This note is applicable to also all the methods described below except
ua() method.

=back

=head2 post ( I<%args> )

=over 4

This method is an alias of post_data() method described above, but
it's already obsolete and remains only for backward compatibility
(less or eaqual version 0.04). Use post_data() instead.

=back

=head2 get_data ( I<%args> )

=over 4

  my $graph_data = $graph->get_data(
      graphname  => $graphname,
      username   => $username,
  );

This method retrieves the data of the graph specified by I<$graphname>
and returns a hashref to them.

=back

=head2 post_config ( I<%args> )

=over 4

  $graph->post_config(
      graphname      => $graphname,
      graphcolor     => $graphcolor,
      graphtype      => $graphtype,
      status         => $status,
      allowuser      => $allowuser,
      allowgrouplist => $allowgrouplist,
      stack          => $stack,
      reverse        => $reverse,
      formula        => $formula,
      maxy           => $maxy,
      miny           => $miny,
      showdata       => $showdata,
      nolabel        => $nolabel,
      userline       => $userline,
      userlinecolor  => $userlinecolor,
      comment        => $comment,
  );

This method sets or updates the configuraions of the graph specified
by I<$graphname>.

=back

=head2 get_config ( I<%args> )

=over 4

  my $graph_config = $graph->get_config( graphname => $graphname );

This method retrieves the configuraions from the graph specified by
I<$graphname> and returns a hashref to them.

=back

=head2 ua ()

=over 4

  $graph->ua->timeout(10);

This method returns LWP::UserAgent object internally used in the
WebService::Hatena::Graph object. You can set some other options which
are specific to LWP::UserAgent via this method.

=back

=head1 SEE ALSO

=over 4

=item * Hatena::Graph

L<http://graph.hatena.ne.jp/>

=item * Hatena::Graph API documentation

L<http://d.hatena.ne.jp/keyword/%a4%cf%a4%c6%a4%ca%a5%b0%a5%e9%a5%d5api>

=back

=head1 AUTHOR

Kentaro Kuribayashi E<lt>kentaro@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE (The MIT License)

Copyright (c) 2006 - 2007, Kentaro Kuribayashi E<lt>kentaro@cpan.orgE<gt>

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

=cut
