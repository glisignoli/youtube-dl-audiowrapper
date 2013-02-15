<?php
@apache_setenv('no-gzip', 1);
@ini_set('zlib.output_compression', 0);
?>
<!DOCTYPE html>
<html>
<body>

	<h1>Youtube to mp3</h1>
		<form name="input" action="convert.php" method="get">
		Youtube url: <input type="text" name="url">
		<input type="submit" value="Submit">
	</form>
	<h1> Current running jobs </h1>
<?php
/**
 * Simple example of extending the SQLite3 class and changing the __construct
 * parameters, then using the open method to initialize the DB.
 */
class MyDB extends SQLite3
{
    function __construct()
    {
        $this->open('youtube-dl.db');
    }
}

$db = new MyDB();

$result = $db->query('SELECT * FROM downloads');
echo "<table border=1>";
echo "<tr>
<td>Title</td>
<td>Size</td>
<td>Percent</td>
<td>Speed</td>
<td>ETA</td>
<td>Status</td>
<td>Added</td>
<td>Link</td>
</tr>";
while( ($row = $result->fetchArray()))
{
    echo "<tr>";
    echo "<td>".$row['Title']."</td>";
    echo "<td>".$row['Size']."</td>";
    echo "<td>".$row['Percent']."</td>";
    echo "<td>".$row['Speed']."</td>";
    echo "<td>".$row['ETA']."</td>";
    echo "<td>".$row['Status']."</td>";
    echo "<td>".$row['DateAdded']."</td>";
    echo "<td>";    
    if ($row['Status'] == 'Finished') {
	echo "<a href=\"".$row['Destination']."\">".$row['Destination']."</a>";
    }
    echo "</td>";
    echo "</tr>";
}
echo "</table>";
?>		
</html> 
