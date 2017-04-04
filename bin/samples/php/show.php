<?php
  include_once("conn.php");
	
	$strId = $_GET["id"];
	if (is_numeric($strId)) {
	  $rs = mysql_query("SELECT * FROM `quiz` WHERE `id`=".$strId);
	  $num = mysql_num_rows($rs);
	  if ($num != 0) {
			$row = mysql_fetch_array($rs, MYSQL_ASSOC);
			
      $strTitle = $row["quizTitle"];
	    $strGuide  = "<table border=1 bordercolor=#7F9DB9 cellpadding=0 cellspacing=0 width=100% style=\"border-collapse: collapse\">\r\n";
      $strGuide .= "  <tr bgcolor=#7F9DB9>\r\n";
			$strGuide .= "	  <td width=\"30%\"><font color=\"#FFFFFF\">测试者</font></td>\r\n";
			$strGuide .= "	  <td width=\"10%\"><font color=\"#FFFFFF\">得分</font></td>\r\n";
			$strGuide .= "	  <td width=\"10%\"><font color=\"#FFFFFF\">试题总分</font></td>\r\n";
			$strGuide .= "	  <td width=\"10%\"><font color=\"#FFFFFF\">及格分</font></td>\r\n";
			$strGuide .= " 	  <td width=\"10%\"><font color=\"#FFFFFF\">是否通过</font></td>\r\n";
			$strGuide .= "	  <td width=\"30%\"><font color=\"#FFFFFF\">提交日期</font></td>\r\n";
			$strGuide .= "	</tr>\r\n";
			$strGuide .= "	<tr>\r\n";
			$strGuide .= "	  <td><a href=mailto:".$row["userMail"]." title='发个邮件给 ".$row["userId"]."'>".$row["userId"]."</a></td>\r\n";
			$strGuide .= "		<td>".$row["userScore"]."</td>\r\n";
			$strGuide .= "	  <td>".$row["totalScore"]."</td>\r\n";
			$strGuide .= "	  <td>".$row["passScore"]."</td>\r\n";
			if ($row["state"]) {
			  $strGuide .= "	  <td><font color=\"#008000\">是</font></td>\r\n";
			}
			else {
			  $strGuide .= "	  <td><font color=\"#FF0000\">否</font></td>\r\n";
			}
			$strGuide .= "	  <td>".$row["addDate"]."</td>\r\n";
			$strGuide .= "	</tr>\r\n";
			$strGuide .= "</table>";
      $strResult = $strGuide."\r\n<br>\r\n".$row["Result"];
			$strResult = str_replace("\'", '"', $strResult);
		}
		else {
			echo "记录未找到！";
	    exit();     
	  }
	}
	else {
    echo "非法的ID值！";
    exit();
  }
?>

<html>

<head>

<meta http-equiv="Content-Type" content="text/html">
<link rel="stylesheet" type="text/css" href="style.css">
<title><?php echo($strTitle) ?> - 测试结果</title>
</head>

<body background="images/bg.gif">
<table width="97%" align="center">
  <tr>
    <td align="center"><font size="4"><?php echo($strTitle) ?></font></td>
  </tr>
  <tr>
    <td><?php echo($strResult) ?></td>
  </tr>
</table>
<br><br>
<center><a href="#" onClick="javascript: self.opener = null; self.close()">关闭窗口</a></center>
</body>

</html>