<?php

// removes text from file in first parameter in file in second parameter, useful to clear malware


if (!isset($argv[1]))
	echo ("example file name is not given");
else
{

	if (!isset($argv[2]))
		echo ("file name to check is not given");
	else
	{
	
		$text = file_get_contents($argv[1]);

		//print_r($text);

		$file = $argv[2];

		$content = file_get_contents($file);

		$content_new = str_replace($text, "", $content);

		//print_r($content_new);
	
		file_put_contents($file, $content_new);
	}

}

?>
