<?php

$dir1 = "/mnt/apache_logs/";
$dir2 = "/mnt/apache/";

$master_key = '123';

$logs = array(
        '456' => $dir1.'site/custom-apache.log',
        '789' => $dir2.'site/www/protected/runtime/application.log'
);

$logs_titles = array(
        '456' => 'site access',
        '789' => 'site application'
);

$strings = array(
        '1' => '1',
        '10' => '10',
        '100' => '100',
        '1000' => '1000'
);

function format_output($output)
{
        $result .= "<pre>\n";
        if (is_array($output))
                foreach($output as $k => $v)
                        $result .= $v."\n";
        else
                $result .= $output;
        $result .= "</pre>";
        return $result;
}

if (isset($_GET['key']) && (isset($logs[$_GET['key']]) || ($_GET['key'] == $master_key)))
{

echo <<<END
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf8" />
<title>Просмотр логов</title>
</head>
<body>
END;

echo ("<h1>Просмотрщик логов - ".$logs_titles[$_GET['key']]."</h1>");


echo ("<form action=\"/log_view/index.php?key=".$_GET['key']."\" method=\"post\">");

if ($master_key == $_GET['key'])
{

        echo ("<table>");

        $trigger = 1;

        foreach($logs as $k => $v)
        {
                if (1 == $trigger)
                        echo ("<tr><td>");

                echo ("<input type=\"radio\" name=\"key\" value=\"".$k."\"");
                if (isset($_POST['key']) && ($k == $_POST['key']))
                        echo (" checked");
                        echo (">".$logs_titles[$k]);

                if (2 == $trigger)
                        echo ("</td></tr>");
                else
                        echo ("</td><td>");

                $trigger++;
                if ($trigger > 2)
                        $trigger = 1;
        }

        echo ("</table>");
}

echo ("<p>Количество строк с конца: ");

foreach($strings as $k => $v)
{
        echo ("<input type=\"radio\" name=\"lines_qty\" value=\"".$k."\"");
        if (isset($_POST['lines_qty']) && ($k == $_POST['lines_qty']))
                echo (" checked");
        echo (">".$k." ");
}


echo <<<END
<input type="submit" name="do_submit" value="Просмотреть"></p>
</form>

END;

if (isset($_POST['do_submit']))
{
        if(isset($logs[$_POST['key']]))
                $key = $_POST['key'];
        else if (isset($_GET['key']))
                $key = $_GET['key'];
        else
                $key = "";

        $filename = $logs[$key];

        exec('tail -n '.$_POST['lines_qty'].' '.$filename.' 2>&1', $output);
        $result = format_output($output);
        echo $result;

}

echo <<<END
</body>
</html>
END;

}

?>

