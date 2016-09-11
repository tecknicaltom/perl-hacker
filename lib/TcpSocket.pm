#!/usr/bin/perl

package TcpSocket;
use parent 'IO::Socket::INET';

use strict;
use warnings;
use diagnostics;
use feature 'say';
use IO::Socket;
use IO::Select;

my $has_hexify = 0;
eval "use Data::Hexify; 1" and $has_hexify = 1;

sub new($$$;@) {
	my $class = shift;
	my $host = shift;
	my $port = shift;

	my %defaults = (
		debug => 0,
		Proto => 'tcp',
		Blocking => 0,
	);
	my %args = ( %defaults, @_,
		PeerAddr => $host,
		PeerPort => $port,
	);

	my $self = $class->SUPER::new(%args);
	${*$self}{debug} = $args{debug};
	binmode $self, ":raw";
	return $self;
}


sub DESTROY($) {
	my $self = shift;
	$self->SUPER::DESTROY();
}

sub tryread($;@)
{
	my $self = shift;

	my %defaults = ( timeout => 5, followup_timeout => 0.1, 
		slurp => 1, until => undef, debug => ${*$self}{debug} );
	my %args = ( %defaults, @_ );
	$args{slurp} = 1 if($args{until});

	my $readbuff = ${*$self}{'readbuff'} || '';
	my $leftover = '';
	my $timeout_happened = 0;
	my $timeout = $args{timeout};

	# if we've already got data in the buffer and we're not waiting
	# for a match, decrease the timeout as if we've already read once
	# and we're looping for more data
	if ($readbuff && !$args{until})
	{
		$timeout = $args{followup_timeout};
	}

	READLOOP:
	while(1)
	{
		if ($timeout_happened || $readbuff)
		{
			if($args{until})
			{
				my $index = index($readbuff, $args{until});
				if($index >= 0)
				{
					$index += length($args{until});
					$leftover = substr($readbuff, $index);
					$readbuff = substr($readbuff, 0, $index);
					last READLOOP;
				}
				if($timeout_happened)
				{
					# timeout without seeing search text... keep
					# what we have in the buffer and return empty
					# string
					($readbuff, $leftover) = ('', $readbuff);
					last READLOOP;
				}
			}
			if(!$args{slurp})
			{
				last READLOOP;
			}
			last READLOOP if($timeout_happened);
		}

		my $set = new IO::Select();
		$set->add($self);
		my @ready = $set->can_read($timeout);
		if(!@ready)
		{
			$timeout_happened = 1;
		}
		foreach my $fh (@ready)
		{
			if($fh == $self)
			{
				my $thisreadbuff;
				my $ret = $self->sysread($thisreadbuff, 100);
				if(not defined($ret) or $ret == 0)
				{
					# closed the socket
					$self->close();
					last READLOOP;
				}
				$readbuff .= $thisreadbuff;
				$timeout = $args{followup_timeout};
			}
		}
	}
	${*$self}{'readbuff'} = $leftover;
	if($args{debug})
	{
		say "Response:";
		say _dumpstr($readbuff);
	}
	return $readbuff;
}

sub print($$;@)
{
	my $self = shift;
	my $data = shift;

	my %defaults = ( debug => ${*$self}{debug} );
	my %args = ( %defaults, @_ );

	if ($args{debug})
	{
		say "Sending:";
		say _dumpstr($data);
	}
	return $self->SUPER::print($data);
}

sub say($$;@)
{
	my $self = shift;
	my $data = shift;
	return $self->print($data . "\n", @_);
}

sub _dumpstr($)
{
	my ($payload) = @_;
	if(!$has_hexify || $payload =~ /^[\w ]*$/)
	{
		say $payload;
	}
	else
	{
		print Hexify($payload);
	}
}

#sub converse($$;@)
#{
#	my $sock = shift;
#	my $payload = shift;
#	my %args = @_;
#
#	$payload .= "\n" unless($args{nonl});
#	if($args{debug})
#	{
#		say "Sending:";
#		say _dumpstr($payload);
#	}
#	print $sock $payload;
#
#	my $response = '';
#	#if($args->{until})
#	$response .= $sock->tryread();
#	if($args{debug})
#	{
#		say "Response:";
#		say _dumpstr($response);
#	}
#	return $response;
#}

1;
