<?

$db = new mysqli('localhost', 'root', 'pblocks', 'pblocks');

// Save the high score
if(!empty($_GET['save']))
{
	$name = $db->real_escape_string($_REQUEST['name']);
	$blockset = $db->real_escape_string($_REQUEST['blockset']);
	$width = $db->real_escape_string($_REQUEST['width']);
	$height = $db->real_escape_string($_REQUEST['height']);
	$depth = $db->real_escape_string($_REQUEST['depth']);
	$score = $db->real_escape_string($_REQUEST['score']);
	$blocksPlayed = $db->real_escape_string($_REQUEST['blocksPlayed']);
	$level = $db->real_escape_string($_REQUEST['level']);
	$query = "insert into highscores (name, blockset, width, height, depth, score, blocksPlayed, level) values ('$name', '$blockset', $width, $height, $depth, $score, $blocksPlayed, $level);";
	$db->query($query);
}

$num_results = 100;
// Generate xml of all the high scores
$query = "select id, name, score, blockset, width, height, depth, blocksPlayed, level, date from highscores order by score desc, blockset, date asc limit $num_results";
$result = $db->query($query);

echo '<?xml version="1.0"?>';
echo '<PaperBlocks>';
echo '<HighScores>';
if($result)
{
	while($row = $result->fetch_assoc())
	{
		echo '<HighScore>';
		echo '<id>' . $row['id'] . '</id>';
		echo '<name>' . htmlspecialchars($row['name'], ENT_QUOTES) . '</name>';
		echo '<mode>' . htmlspecialchars($row['blockset'], ENT_QUOTES) . ' (' . $row['width'] . ', ' . $row['height'] . ', ' . $row['depth'] . ')</mode>';
		echo '<score>' . $row['score'] . '</score>';
		echo '<blocksPlayed>' . $row['blocksPlayed'] . '</blocksPlayed>';
		echo '<level>' . $row['level'] . '</level>';
		echo '<date>' . $row['date'] . '</date>';
		echo '</HighScore>';
	}
}

echo '</HighScores>';
echo '</PaperBlocks>';

$db->close();

?>
