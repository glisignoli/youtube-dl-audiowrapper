This is a pretty terrible mash up of scipts to acomplish something fairly simple.
Perl, php and a modified youtube-dl were used.

Basically....

youtube2mp3.php -> Reads an sqlite database of your current and completed downloads
convert.php -> sends the job off to youtube-dl-wrapper.pl, checks to make sure the url is valid
youtube-dl-wrapper -> runs the job, logs the output of youtube-dl to a sqlite database
youtube-dl -> a modified binary with the --newline option

Requirements:
sqlite extensions of php and perl (DBI).

Bugs:
There's some issues with the sqlite database being locked. I'm too lazy to fix it.

Notes:
I've only tested it for youtube, and not for playlists.
It's really only designed for downloading youtube's to audio. I might make a pure php wrapper later, but what I have works.

Installation:
Everything goes in one directory. Works for me.
