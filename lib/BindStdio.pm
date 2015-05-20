#!/usr/bin/perl

package BindStdio;
use Exporter 'import';
@EXPORT_OK = qw(bind_stdio);

use strict;
use warnings;
use diagnostics;
use IO::Select;

sub bind_stdio($)
{
	my ($sock) = @_;
	my $set = new IO::Select();
	$set->add($sock);
	$set->add(*STDIN);
	my $socket_set = new IO::Select();
	$socket_set->add($sock);
	my $stdin_set = new IO::Select();
	$stdin_set->add(*STDIN);
	defined($sock->blocking(0))
		or die("unable to set socket to nonblocking: [$!]");
	defined(*STDIN->blocking(0))
		or die("unable to set stdin to nonblocking");
	$| = 1;
	while(1){
		while(my @ready = $set->can_read(1))
		{
			my $buffer;
			foreach my $fh (@ready)
			{
				if ($fh->fileno == fileno STDIN)
				{
					my $bytes = STDIN->sysread($buffer, 1024) or return;
					$sock->write($buffer);
				}
				if ($fh->fileno == $sock->fileno)
				{
					my $bytes = $sock->sysread($buffer, 1024) or return;
					STDOUT->write($buffer);
				}
			}
		}
	}
}

1;
