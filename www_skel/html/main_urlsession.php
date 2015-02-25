<?php

// we have a really simple "database" of credentials :-)
$authenticated = ($_POST['username'] == "secappdev") &&
                        ($_POST['password'] == "secret" );

require '../config/urlsessionids.php';

function login_success() {
        global $sessionid;
        echo "<P>Login successful, <STRONG>SecAppDev Student</STRONG>!</P>\n";
        echo "<P>Look at some <A href='content_urlsession.php?sessionid=".$sessionid."'>content</A>.</P>\n";
}

function login_failure() {
        echo "<P>Login failed!</P>\n";
        echo "<P>Return to the <A href='index.php'>login form</A>.\n";
}
?>

<HTML>
<HEAD>
        <TITLE>Main page</TITLE>
        <LINK rel="stylesheet" type="text/css" href="http://www.tls.now/fluff.css" />
<!--    <LINK rel="stylesheet" type="text/css" href="fluff.css" /> -->
</HEAD>
<BODY>
<H1>Main page</H1>

<?php
        if ( $authenticated ) {
                login_success();
        } else {
                login_failure();
        }
?>

</BODY>
</HTML>
