<?php
require_once("../lib/json_encode.php");

$BD_PATH = "../../bd/ppp/leaderboard.xml";

$entries = [];
if (file_exists($BD_PATH)) {
	$bd = simplexml_load_file($BD_PATH);
    foreach ($bd->entry as $entry) {
        $entries[strval($entry->name)] = intval($entry->score);
    }
}

arsort($entries);

$json = json_encode($entries);
if($json){
    echo $json;
}


?>