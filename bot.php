<?php

$piece = to_a($_REQUEST['piece']);
$board = explode(' ',$_REQUEST['board']);

$defaults = array(
'wall_below' => 1,
'piece_below' => 1,
'wall_on_left' => 1,
'piece_on_left' => 1,
'wall_on_right' => 1,
'piece_on_right' => 1,
'space_filled' => 7,
'blank_space_below' => -6,
'top_modifier' => 1,
'bonus_modifier' => 1);

$ga = array_merge($defaults,$_REQUEST);

//print_r($board);

//$debug = true;

if($debug)
	echo '<pre>';

$max_score = 0;
for($i = 0; $i < 4; $i++)
{
	$piece = rotate($piece);
	$width = width($piece);
	for($pos = 0; $pos < 11 - $width; $pos ++)
	{
		$score = score($piece,$pos, $board);
		if($score > $max_score)
		{
			$max_pos = $pos;
			$max_deg = ($i + 1) * 90;
			$max_score = $score;
		}
	}

}

if($debug)
{
	$piece = rotate_deg($piece,$max_deg);
	for($i = 0; $i < count($piece); $i++)
	{
		for($j = 0; $j < count($piece[$i]); $j++)
		{
			if($piece[$i][$j] == 1)
				$board[$i]{$max_pos + $j} = $_REQUEST['piece'];
		}
	}
	foreach($board as $row)
		echo "$row\n";
}

echo "position=$max_pos&degrees=$max_deg";

function score($piece,$position, $board)
{
	global $debug;
	global $ga;
	$good = true;
	$width = width($piece);
	$top = 0;
	for($top = 0; $top < 20 && $good; $top ++)
	{
		$bonus = 0;
		for($i = -1; $i < count($piece) + 1; $i++)
		{
			for($j = -1; $j < $width + 1; $j++)
			{
				$pixel = $board[$top + $i]{$position + $j};
				if (!$pixel)
					$pixel = 'x';
				if($debug)
				{
					if($piece[$i][$j] == 1)
						echo $piece[$i][$j];
					else
						echo $pixel;
				}
				if(preg_match("/[ijlostzx]/",$pixel))
				{
					if($top == 0 && $piece[$i][$j])
						return 0;

					if($piece[$i - 1][$j] == 1)
					{
						$good = false;
						if($pixel == 'x')
							$bonus += $ga['wall_below'];
						else
							$bonus += $ga['piece_below'];
					}
					if($piece[$i][$j + 1] == 1)
					{
						if($pixel == 'x')
							$bonus += $ga['wall_on_left'];
						else
							$bonus += $ga['piece_on_left'];
					}
					if($piece[$i][$j - 1] == 1)
					{
						if($pixel == 'x')
							$bonus += $ga['wall_on_right'];
						else
							$bonus += $ga['piece_on_right'];
					}

					if(isset($piece[$i][$j]) && $piece[$i][$j] == 0)
						$bonus += $ga['space_filled'];
				}
				elseif(!($piece[$i][$j]) && $pixel == '.' && $piece[$i - 1][$j])
				{
					$bonus += $ga['blank_space_below'];
				}
			}
			if($debug)
				echo "\n";
		}
		if($debug)
			echo "---\n";
	}
	global $debug;
	if($debug)
		echo "Top: $top Bonus: $bonus\n";
	$total = $top * $ga['top_modifier'] + $bonus * $ga['bonus_modifier'];
	return $total;
}

function width($piece)
{
	$width = 0;
	foreach($piece as $row)
		$width = max($width,count($row));
	return $width;
}

function to_a($piece)
{
	switch($piece) {
	case 'i':
		$a = array(array(1),array(1),array(1),array(1));
		break;
	case 'j':
		$a = array(array(0,1),array(0,1),array(1,1));
		break;
	case 'l':
		$a = array(array(1,0),array(1,0),array(1,1));
		break;
	case 'o':
		$a = array(array(1,1),array(1,1));
		break;
	case 's':
		$a = array(array(0,1,1),array(1,1,0));
		break;
	case 't':
		$a = array(array(1,1,1),array(0,1,0));
		break;
	case 'z':
		$a = array(array(1,1,0),array(0,1,1));
		break;
	}
	return $a;
}

function rotate_deg($piece,$deg)
{
	for($i = $deg; $i > 0; $i-= 90)
		$piece = rotate($piece);
	return $piece;
}

// Rotate piece once clockwise
function rotate($piece_a)
{
	$max_row = 0;
	foreach($piece_a as $row)
	{
		$max_row = max(count($row),$max_row);
	}
	$r = array();
	for($i = 0; $i < $max_row; $i++)
	{
		$r[$i] = array();
		foreach($piece_a as $j => $p_row)
		{
			$r[$i][$j] = $piece_a[count($piece_a) - $j - 1][$i];
		}
	}
	return $r;
}

function print_piece($piece_a)
{
	foreach($piece_a as $row)
	{
		foreach($row as $col)
		{
			if($col == 1)
				echo '#';
			else
				echo ' ';
			
			
		}
		echo "\n";
	}
}

//print_piece($piece);
//echo score($piece,2,180,$board);

if($debug)
	echo '</pre>';
?>
