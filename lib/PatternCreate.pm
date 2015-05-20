#!/usr/bin/perl

package PatternCreate;
use Exporter 'import';
@EXPORT_OK = qw(pattern_create pattern_offset);

use strict;
use warnings;
use diagnostics;

sub pattern_create($)
{
	my ($max) = @_;
	my @sets = (['A'..'Z'], ['a'..'z'], ['0'..'9']);
	my @indices = (0) x @sets;
	my $len = 0;
	my $set_ind = 0;
	my $out = '';

	while(1)
	{
		last if($len >= $max);

		$out .= $sets[$set_ind]->[$indices[$set_ind]];
		$len++;
		$set_ind = ($set_ind + 1) % @sets;

		if ($set_ind == 0)
		{
			my $tmp = $#sets;
			$indices[$tmp]++;
			while($indices[$tmp] >= @{$sets[$tmp]})
			{
				$indices[$tmp] = 0;
				$tmp--;
				$indices[$tmp]++;
			}
		}
	}
	return $out;
}

sub pattern_offset($)
{
	my ($needle) = @_;
	$needle = $1 if($needle =~ /^0x([0-9a-f]*)/);
	$needle = pack('V*', hex($needle)) if(length($needle) >= 8 and $needle =~ /^[0-9a-f]+$/i and hex($needle) > 0);
	my $pattern = pattern_create(8192);
	my $offset = index($pattern, $needle);
	my @offsets = ();
	while($offset >= 0)
	{
		#if(!wantarray())
		{
			return $offset;
		}
		push @offsets, $offset;
		$offset = index($pattern, $needle, $offset+1);
	}
	if(wantarray())
	{
		return ();
	}
	return undef;
}

1
