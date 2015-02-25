<?php
require '../config/urlsessionids.php';

// check that session id is "valid"
$insession = ($_GET['sessionid'] == $sessionid);

function display_content() {
        echo "<P>Good session!</P>\n";
        echo "<P>Lorem ipsum...</P>\n";
}

function session_failure() {
        echo "<P>No active session!</P>\n";
        echo "<P>Please <A href='index.php'>log in</A>.\n";
}
?>

<HTML>
<HEAD><TITLE>Content page</TITLE></HEAD>
<BODY>
<H1>Content page</H1>

<?php
        if ( $insession ) {
                display_content();
        } else {
                session_failure();
        }
?>

</BODY>
</HTML>
