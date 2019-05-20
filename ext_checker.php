<?php

// Some checks if ext directory names and structure correct
// Copyright © Oyabun1 2013
// version 0.9.1
// license http://opensource.org/licenses/GPL-2.0 GNU General Public License v2

function find_file($dirs, $filename)
{
	$dir = @scandir($dirs);
	if(is_array($dir) AND !empty($dir))
	{
		foreach($dir as $file)
		{
			if(($file !== '.') AND ($file !== '..'))
			{
				if (is_file($dirs.DIRECTORY_SEPARATOR.$file))
				{
					$filepath =  realpath($dirs.DIRECTORY_SEPARATOR.$file);
			 
					$pos = strpos($file,$filename);
					
					if($pos === false) 
					{}
					else 
					{
						if(file_exists($filepath) AND is_file($filepath))
						{
							$phpbb_root = 
							$contents = file_get_contents($filepath);
							$json = json_decode($contents, true);
							if (json_last_error() === JSON_ERROR_NONE)
							{
								if(isset($json["extra"]["display-name"]))
								{
									$ext_disp_name = $json["extra"]["display-name"];
									echo 'Display name in composer.json: <span style="font-weight: 900;">' . $ext_disp_name . '</span><br />';
								}
								else
								{
									echo '<span style="color:red;">Display name not found in composer.json</span><br />';
								}
								if(isset($json["version"]))
								{
									$ext_version = $json["version"];
									echo 'Version in composer.json: ' . $ext_version . '<br />';
								}
								else
								{
									echo '<span style="color:red;">Display name not found in composer.json</span><br />';
								}
								if(isset($json["name"]))
								{
									$ext_name = $json["name"];
									if (strpos($filepath, $ext_name) !== false)
									{
										echo 'Name in composer.json: <span style="color:green;">' . $ext_name . '</span><br />';
									}
									else
									{
										echo 'Name in composer.json: <span style="color:red;">' . $ext_name .'</span><br />';
									}
								}
								else
								{
									echo '<span style="color:red;">Name not found in composer.json</span><br />';
								}
							}
							else
							{
								switch (json_last_error()) 
								{
								case JSON_ERROR_DEPTH:
									echo ' - The maximum stack depth has been exceeded<br />';
								break;
								case JSON_ERROR_STATE_MISMATCH:
									echo ' - Invalid or malformed JSON';
								break;
								case JSON_ERROR_CTRL_CHAR:
									echo ' - Control character error, possibly incorrectly encoded<br />';
								break;
								case JSON_ERROR_SYNTAX:
									echo ' - Syntax error, malformed JSON<br />';
								break;
								case JSON_ERROR_UTF8:
									echo ' - Malformed UTF-8 characters, possibly incorrectly encoded<br />';
								break;
								default:
									echo ' - Unknown error<br />';
								break;
								}
							}
							$composer_path = str_replace(__DIR__, '', $filepath);
							if(isset($json["name"]))
							{
								$part_path = 'ext' . DIRECTORY_SEPARATOR . $ext_name;
							}
							else
							{
								$part_path = '';
							}
							if (strpos($composer_path, $part_path) !== false)
							{
								$path_chk = '<span style="color:green;">' . $composer_path . '</span>'; 
							}
							else
							{
								$path_chk = '<span style="color:red;">' . $composer_path . '</span>';
							}
							
							echo 'Path to composer.json: ' . $path_chk . '<br />composer.json file access permissions &equiv; ' . substr(decoct(fileperms($filepath)),3) . '<br /><br />';
						}
						
					}
				}
				else
				{
					find_file($dirs.DIRECTORY_SEPARATOR.$file,$filename);
				}
			}			
		}	
	}
}

// Check if in board root
if(file_exists('config.php') && file_exists('viewforum.php'))
{
	// Check if ext folder exists
	if(file_exists('ext'))
	{
		// OK do stuff
		find_file('ext','composer.json');
	}
	else
	{
		echo '/ext folder not found. Are you sure this is a 3.1.x installation?<br />';
	}
}
else
{
	echo 'File does not seem to be in the root of your phpBB installation.<br />';
}	
