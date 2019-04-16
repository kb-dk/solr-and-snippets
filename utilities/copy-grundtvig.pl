#!/usr/bin/perl -w

use strict;

#
# This is so specific Grundtvigs Værker that it won't be useful for anything else
#
# In case you'd like to configure where you keep the GV
#

my $where_is_grundtvig = "../GV/";

if( open(my $gv, "(cd $where_is_grundtvig ;  find . -regextype sed -regex '^.*18[0-9][0-9]GV.*\$' -type f -print)|") ) {
    while(my $file = <$gv>) {
	print $file;
    }
}
