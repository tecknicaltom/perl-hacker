#!/usr/bin/perl

package IntPacker;
use Exporter 'import';
@EXPORT_OK = qw(p up);

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
