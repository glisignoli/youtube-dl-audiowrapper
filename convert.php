<?php
@apache_setenv('no-gzip', 1);
@ini_set('zlib.output_compression', 0);

$url = $_GET["url"];

if (filter_var($url, FILTER_VALIDATE_URL) !== false) {
    	system("/var/www/youtube-dl-wrapper.pl \"$url\" > /dev/null 2>&1 &");
}

header("Location: youtube2mp3.php"); 
?>
