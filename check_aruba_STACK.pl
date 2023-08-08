#!/usr/bin/perl
##################################################################
# Creation: Skrabal Arnault
# Last Modification:
# 
# Test intégité d'un stack VSF
#
##################################################################


use strict;
use warnings;



my $OID_STACKSTATEMENBER = 'HP-STACK-MIB::hpStackMemberEntryStatus';

my $STATE_OK = 0;
my $STATE_WARNING = 1;
my $STATE_CRITICAL = 2;
my $STATE_UNKNOWN = 3;
my $STATE_DEPENDENT = 4;
my $STATE = 3;


my $Command = "snmpwalk -v $ARGV[0] -c $ARGV[1] $ARGV[2] $OID_STACKSTATEMENBER";
my $result = `$Command`;
#$result =~ m/IF-MIB::ifDescr\.(\d+)\s=\s.*$interface.*/;
my $Menber = -1;
my $MenberMissing = 0;
foreach(split("HP-STACK-MIB::hpStackMemberEntryStatus.",$result))
{
$Menber++;
	if($_ =~ "missing")
	{
		$MenberMissing = $Menber;
	}
}

if($MenberMissing != 0)
{
	print "Stack ERROR Menber $MenberMissing is MISSING";
	$STATE = $STATE_CRITICAL;
}
else
{
	print "Stack $Menber menber";
	$STATE = $STATE_OK;
}

exit $STATE;
