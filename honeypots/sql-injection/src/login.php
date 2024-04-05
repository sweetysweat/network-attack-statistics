<?php
class MyDB extends SQLite3 {
    function __construct() {
        $this->open('../db.sqlite', SQLITE3_OPEN_READONLY);
    }
}
$db = new MyDB();

if($_SERVER["REQUEST_METHOD"] == "POST") {

    $myusername = $_POST['username'];
    $mypassword = $_POST['password'];
    
    $sql = "SELECT * FROM users WHERE username = '$myusername' and password = '$mypassword'";

    $log = date("Y-m-d H:i:s")." SQL:".$sql.PHP_EOL;
    file_put_contents('/var/log/app/sql_'.date("Y-m-d").'.log', $log, FILE_APPEND);

    $result = $db->query($sql);
    $row = $result->fetchArray(SQLITE3_ASSOC);
    
    if($row) {
        $page = file_get_contents("../stats.html");
        $page = str_replace("XXAVATARXX", $row["avatar"], $page);
        $page = str_replace("XXUSERNAMEXX", $row["username"], $page);
        $page = str_replace("XXNAMEXX", $row["name"], $page);
        $page = str_replace("XXTITLEXX", $row["title"], $page);
        $page = str_replace("XXAGEXX", $row["age"], $page);
        echo $page;
    } else {
        header("Debug: ".$sql);
        echo 'Your Login Name or Password is invalid <a href="/index.html">Try again</a>';
    }
}
?>
