#!/usr/bin/perl

package PerlHacker::IntPacker;
use Exporter 'import';
our @EXPORT_OK = qw(p up p64 up64);
our %EXPORT_TAGS = (all => [@EXPORT_OK]);

use strict;
use warnings;
use diagnostics;

# shortcut for packing addresses/longs
sub p($)
{
	$_ = shift;
	return pack('V', $_);
}

# shortcut for unpacking addresses/longs
sub up($)
{
	$_ = shift;
	return unpack('V', $_);
}

# shortcut for packing 64-bit addresses/longs
sub p64($)
{
	$_ = shift;
	return pack('Q', $_);
}

# shortcut for unpacking 64-bit addresses/longs
sub up64($)
{
	$_ = shift;
	return unpack('Q', $_);
}
