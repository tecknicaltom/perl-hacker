#!/usr/bin/perl

package PatternCreate;
use Exporter 'import';
@EXPORT_OK = qw(pattern_create pattern_offset);

use strict;
use warnings;
use diagnostics;
use Carp;

use constant {
	MODE_METASPLOIT => 0,
	MODE_PEDA => 1,
};

our $Mode = MODE_METASPLOIT unless defined $Mode;
our $SearchLength = 8192 unless defined $SearchLength;

sub pattern_create($)
{
	my ($max) = @_;
	return pattern_create_metasploit($max) if($Mode == MODE_METASPLOIT);
	return pattern_create_peda($max) if($Mode == MODE_PEDA);
	croak "Unknown value for PatternCreate::Mode";
}

sub pattern_offset($)
{
	my ($needle) = @_;
	$needle = $1 if($needle =~ /^0x([0-9a-f]*)/);
	$needle = pack('V*', hex($needle)) if(length($needle) >= 8 and $needle =~ /^[0-9a-f]+$/i and hex($needle) > 0);
	my $pattern = pattern_create($SearchLength);
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

# Metasploit-compatible patterns

sub pattern_create_metasploit($)
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

# PEDA-compatible pattern

my $peda_extended_charset = 'A%sB$nC-(D;)Ea0Fb1Gc2Hd3Ie4Jf5Kg6Lh7Mi8Nj9OkPlQmRoSpTqUrVtWuXvYwZxyz';

sub de_bruijn($$$)
{
	my ($charset, $n, $maxlen) = @_;
	my @a = (0) x (length($charset) * $n);
	my @sequence;

	sub db($$$$$$$);
	sub db($$$$$$$)
	{
		my ($charset, $n, $maxlen, $a, $sequence, $t, $p) = @_;
		return if scalar(@$sequence) == $maxlen;

		if($t > $n)
		{
			if($n % $p == 0)
			{
				foreach my $j (1 .. $p)
				{
					push @$sequence, substr($charset, $a->[$j], 1);
					return if scalar(@$sequence) == $maxlen;
				}
			}
		}
		else
		{
			$a->[$t] = $a->[$t - $p];
			db($charset, $n, $maxlen, $a, $sequence, $t+1, $p);
			foreach my $j ($a->[$t - $p] + 1 .. length($charset)-1)
			{
				$a->[$t] = $j;
				db($charset, $n, $maxlen, $a, $sequence, $t+1, $t);
			}
		}

	}
	db($charset, $n, $maxlen, \@a, \@sequence,  1, 1);

	return join '', @sequence;
}

sub pattern_create_peda($)
{
	my ($max) = @_;
	return de_bruijn($peda_extended_charset, 3, $max);
}

1
