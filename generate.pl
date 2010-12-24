#!/usr/local/bin/perl

#Solodovnikov Timur
use strict;
use Config::IniFiles;

my $name = undef;
my %ini;
tie %ini, 'Config::IniFiles', ( -file => "./CONFIG.INI" );


my $ipaddr = $ARGV[4];
#my $NAME=$ARGV[2];
my $LOCATION=$ARGV[3];

if (!($ARGV[4])) 
{
print  "Usage: project smus|ring|1(if PON) name location ipaddr
Example:
./generate.pl gor 1 streetp1-2 \"Russia NN\" 10.82.133.1
./generate.pl md 3 streetp1-2 \"Russia NN\" 172.22.133.5

Possible projects: "; 
foreach (keys %ini)
    {
    print $_," " if $_ ne 'GLOBAL';
    }
print "\n";    
die;
}
###Chek INI File
die "Not defined project $ARGV[0] in CONFIG.INI" if not defined $ini{$ARGV[0]};
die "Not defined ring $ARGV[1] in project $ARGV[0] in CONFIG.INI" if ( $ini{$ARGV[0]}{scheme} && not defined $ini{$ARGV[0]}{$ARGV[1]});




my @result = `m4 ./mc/$ARGV[0].mc`;

 $name = "$ARGV[2].r$ARGV[1].$ARGV[0]" if lc($ini{$ARGV[0]}{'scheme'}) =~ m/rings/; 
 $name = "$ARGV[2].s$ARGV[1].$ARGV[0]" if lc($ini{$ARGV[0]}{'scheme'}) =~ m/smus/; 
 $name = "$ARGV[2].$ARGV[0]" if not $ini{$ARGV[0]}{scheme}; 

open (OUT, ">./done/$name.txt") or die "Can't open file ./done/$name.txt"; 

foreach my $line (@result)
{
#UNIX to WINDOWS EOL
#Comment here if you whant output configs in Unix EOL format
$line =~ s/\012/\015\012/g;

$line =~ s/_NAME/$ARGV[2]/;
$line =~ s/_LOCATION/$ARGV[3]/;
$line =~ s/_IPADDR/$ARGV[4]/;
$line =~ s/_SWgate_/$ini{$ARGV[0]}{'SWgate'}/;
$line =~ s/_SW_MASK_LEN/$ini{$ARGV[0]}{'SWnetmask'}/;
$line =~ s/_LOCATION/$ARGV[3]/;
$line =~ s/_SWcontroltag_/$ini{$ARGV[0]}{'SWcontroltag'}/;
$line =~ s/_SWpass_/$ini{GLOBAL}{SWpass}/;
$line =~ s/_SWrcomm_/$ini{GLOBAL}{SWrcomm}/;
$line =~ s/_SWrwcomm_/$ini{GLOBAL}{SWrwcomm}/;
$line =~ s/_SWsnmpserv_/$ini{GLOBAL}{SWsnmpserv}/;
$line =~ s/_UTAG/$ini{$ARGV[0]}{$ARGV[1]}/ if defined $ini{$ARGV[0]}{$ARGV[1]};
$line =~ s/_LocalEn_/$ini{$ARGV[0]}{LocalEn}/;
$line =~ s/_SWntpdserv1_/$ini{GLOBAL}{SWntpdserv1}/;
$line =~ s/_SWntpdserv2_/$ini{GLOBAL}{SWntpdserv2}/;


$line =~ s/_Uunknownpoolnet_/$ini{$ARGV[0]}{'Uunknownpoolnet'}/;
$line =~ s/_Uunknownpoolmask_/$ini{$ARGV[0]}{'Uunknownpoolmask'}/;
$line =~ s/_Ugate_/$ini{$ARGV[0]}{'Ugate'}/;


print OUT $line;
}
close OUT;


print <<EOF;                                                                                                                                                
Some text...
config saved in ./done/$name.txt


EOF


