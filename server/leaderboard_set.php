<?php
require_once("../lib/json_decode.php");

$BD_PATH = "../../bd/ppp/leaderboard.xml";

$json = file_get_contents('php://input');
$data = json_decode($json);

$name = $data->name;
$score = $data->score;


if($name == "" || $score == 0){
    exit();
}

$entries = [];
if (file_exists($BD_PATH)) {
	$bd = simplexml_load_file($BD_PATH);
    foreach ($bd->entry as $entry) {
        $entries[strval($entry->name)] = intval($entry->score);
    }
}

if(count($entries) < 100){
    if(!array_key_exists($name, $entries)){
        $entries[$name] = $score;
    }
    else{
        if($score > $entries[$name]){
            $entries[$name] = $score;
        }
        
    }
}
else{
    if(!array_key_exists($name, $entries)){
        $min_value = min($entries);
        $min_index = array_search($min_value, $entries);
    }
    else{
       $min_value = $entries[$name];
       $min_index = $name; 
    }

    if($score > $min_value){
        unset($entries[$min_index]);
        $entries[$name] = $score;
    }
}

$bd = new SimpleXMLElement("<?xml version=\"1.0\" encoding=\"utf-8\" ?><Leaderboard></Leaderboard>");
foreach($entries as $n => $s){
    $entry = $bd->addChild('entry');
    $entry->name = $n;
    $entry->score = $s;
}

$bd->saveXML($BD_PATH);


?>