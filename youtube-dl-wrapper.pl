#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: youtube-dl-wrapper.pl
#
#        USAGE: ./youtube-dl-wrapper.pl "youtubeurl"
#
#  DESCRIPTION: Sqlite wrapper for youtube-dl, requires newline support
#
#      OPTIONS: ---
# REQUIREMENTS: youtube-dl with newline support
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Gino Lisignoli
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 02/13/2013 01:06:01 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use Data::Dumper;
use DBI;
use Time::Piece;
use File::Copy;

#Destination var
my $destination = "";

#Video url
my $videourl="$ARGV[0]";

#Database filename
my $dbfile="youtube-dl.db";
my $dbh = DBI->connect("dbi:SQLite:dbname=$dbfile","","");

#Create the database unless it already exists
my $statement = "";
$statement = "CREATE TABLE IF NOT EXISTS downloads(Title TEXT, Destination TEXT, Percent TEXT, Size TEXT, Speed TEXT, ETA TEXT, Status TEXT, DateAdded TEXT, DateFinished TEXT, YoutubeLink TEXT);";

my $query_handle = $dbh->prepare($statement);
$query_handle->execute();

#First, insert the youtube link into the table, then get the newly created row id:
my $date = localtime;

$statement = "INSERT INTO downloads (YoutubeLink, DateAdded, Status) VALUES ('$videourl', '$date', 'Starting');";
$query_handle = $dbh->prepare($statement);
$query_handle->execute();


$statement = "SELECT last_insert_rowid()"; 
$query_handle = $dbh->prepare($statement);
$query_handle->execute();

my @ID = $query_handle->fetchrow_array;

#Run youtube-dl
my $youtubeid = "";
open my $youtubedl, '-|', "./youtube-dl -v -t --extract-audio --newline \"$videourl\"";
while (<$youtubedl>) {
	#For each line, parse outout
	#Case for youtube id
	if ($_ =~ m/\[youtube\] .*: Downloading video webpage/) {
		$youtubeid = $_;
		$youtubeid =~ /\[youtube\] (.*): Downloading video webpage/;
		$youtubeid = $1;
	}
	#Case for destination
	if ($_ =~ m/\[download\] Destination:.*/) {
		# Get just the destination name:
		$_ =~ s/\[download\] Destination: //;
		$destination = $_;
		$destination = $dbh->quote($destination);

		my $title = $_;
		$title =~ s/-$youtubeid.*//;
		chomp $title;
		$title = $dbh->quote($title);
		#Update the table for the Destination filename
		$statement = "UPDATE downloads SET Destination=$destination,Title=$title WHERE rowid=$ID[0];";
		$query_handle = $dbh->prepare($statement);
		$query_handle->execute();
	}
	#Case for download status
	if ($_ =~ m/\[download\].*ETA.*/) {
		#get the % complete, the file size, the speed and the ETA time
		my $percent = $_;
		my $size = $_;
		my $speed = $_;
		my $eta = $_;
	
		$percent =~ /([0-9]{1,3}\.[0-9]?)\%/;
		$percent = $1;

		$size =~ /.*of ([0-9]+\.[0-9]*[MkGgKbB]+) at.*/;
		$size = $1;

		$speed =~ /([0-9]*\.[0-9]*[MkbB]{1,2}\/s)/;
		$speed = $1;

		$eta =~ /([-]{0,2}[0-9]{0,2}:[-]{0,2}[0-9]{0,2})/;
		$eta = $1;
		
		#update the row containing the info
        $statement = "UPDATE downloads SET Percent='$percent', Size='$size', Speed='$speed', ETA='$eta', Status='Downloading'  WHERE rowid=$ID[0]";
        $query_handle = $dbh->prepare($statement);
        $query_handle->execute();
	}
	#Case for avconv
	if ($_ =~ m/\[avconv\].*/) {
		#Update the destination:
		$destination = $_;
		$destination =~ s/\[avconv\] Destination: //;
		$destination = $dbh->quote($destination);
		
		#Update row to updating
		$statement = "UPDATE downloads SET Status='Converting', Destination=$destination WHERE rowid=$ID[0];";

        $query_handle = $dbh->prepare($statement);
        $query_handle->execute();
	
	}
}

$date = localtime;
$statement = "UPDATE downloads SET Status='Finished', DateFinished='$date' WHERE rowid=$ID[0]";
$query_handle = $dbh->prepare($statement);
$query_handle->execute();
#Add date finished time
close($youtubedl);
