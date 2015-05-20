#!/usr/bin/perl

package TcpSocket;

use strict;
our @ISA;
use warnings;
use diagnostics;
use IO::Socket;
use Fcntl qw(F_GETFL F_SETFL O_NONBLOCK);
use IO::Select;

@ISA = qw(IO::Socket::INET);

my %_data;

sub new($$$;&) {
	my $class = shift;
	my $host = shift;
	my $port = shift;
	my $code = \&{ shift @_ } if(@_);

	my $self = $class->SUPER::new(
		Proto => 'tcp'
		);
	$_data{$self} = {
		host => $host,
		port => $port,
		code => $code,
	};
	$self->_connect();
	return $self;
}

sub _connect($)
{
	my $self = shift;
	my $foo = $self->configure({
			PeerPort=>$_data{$self}->{port},
			PeerAddr=>$_data{$self}->{host},
			Blocking=>0,
			Proto=>'tcp',
		});
	binmode $self, ":raw";

	my $code = $_data{$self}->{code};
	if ($code)
	{
		$_ = $self;
		$code->($self);
	}

	return $self;
}

sub reconnect($)
{
	my $self = shift;
	$self->close();
	$self->_connect();
}

sub DESTROY($) {
	my $self = shift;
	delete $_data{$self};
	$self->SUPER::DESTROY();
}

sub tryread($;$)
{
	my $sock = shift;
	my $wholeread = "";
	my $thisread;
	my $ret;

	my $timeout = 5;
	$timeout = shift if(@_);
	my $slurp = 1;
	$slurp = shift if(@_);
	#print "timeout: $timeout\n";
	#print "slurp $slurp\n";


	my $set = new IO::Select();
	$set->add($sock);
	while(my @ready = $set->can_read($timeout))
	{
		foreach my $fh (@ready)
		{
			if($fh->fileno == $sock->fileno)
			{
				my $ret = $fh->sysread($thisread, 100);
				if(not defined($ret) or $ret == 0)
				{
					# closed the socket
					$fh->close();
					return $wholeread;
				}
				$wholeread .= $thisread;
				return $wholeread if(!$slurp);
				$timeout = 0.01;
			}
		}
	}
	return $wholeread;
}

1;
