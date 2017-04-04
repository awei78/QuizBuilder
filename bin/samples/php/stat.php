<?php
  include_once("conn.php");

  $strType =$_GET["type"];
  if ($strType == "") { 
	  $strType = "quiz";
	}
	$strSort = ($strType == "quiz") ? "quizTitle" : "userId";
  $strPage = $_GET["page"];
  if ($strPage == "") {
	  $strPage = 1;
	}
	
  //据登录管理员设置查询
	$strSql = "SELECT ".$strSort.", regMail, ";
	$strSql .= "(SELECT Max(userScore) FROM quiz WHERE ".$strSort."=a.".$strSort." AND regMail=a.regMail) AS maxScore, ";
	$strSql .= "(SELECT Min(userScore) FROM quiz WHERE ".$strSort."=a.".$strSort." AND regMail=a.regMail) AS minScore, ";
	$strSql .= "(SELECT Avg(userScore) FROM quiz WHERE ".$strSort."=a.".$strSort." AND regMail=a.regMail) AS avgScore, ";	
	$strSql .= "Count(id) AS quizCount, Sum(passState) AS passCount, Sum(NOT passState) AS failCount FROM quiz a";		
  if ($_SESSION["sys"]) {
    //
  }
	elseif ($_SESSION["admin"] != "") {
    $strSql .= " WHERE regMail='".$_SESSION["admin"]."'";
  }
	else{
    $strSql .= " WHERE regMail=''";
  }
	$strSql .= " GROUP BY ".$strSort.", regMail";
?>
<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=gb2312">
<link rel="stylesheet" type="text/css" href="style.css">
<meta name="Keywords" content="秋风软件, 秋风试题大师, 秋风人事档案管理系统, E-Learning, SCORM">
<title>秋风试题大师数据管理系统 - 试题信息统计</title>
<script language="javascript">
<!--
  function showPie(p, f, t, u, admin) {
    if (window.navigator.userAgent.indexOf("MSIE") >= 1) { 
			var w = window.open("pie.php?p="+ p +"&f="+ f + "&t=" + t + "&u=" + u + "&a=" + admin, "图表显示", "height=445, width=625, toolbar=no, menubar=no, scrollbars=no, resizable=no,location=no, status=no"); 
      w.focus();
    }
    else {
      alert("您的浏览器不是基于IE的浏览器，不支持图表显示功能。");
    }
  }
-->
</script>

</head>

<body onLoad="javascript: document.all.cbType.focus()">

<center>
<table border="1" width="100%" cellpadding="0" cellspacing="0" bordercolor="#7F9DB9" style="border-collapse: collapse">
  <tr>
    <td colspan="10" align="center" height="20"><b><font size="3" color="#006699">试题信息统计</font></b></td>
  </tr>
  <tr>
    <td background="images/tbg.gif" width="4%" height="20">序号 </td>
    <td background="images/tbg.gif" width="34%" height="20"><?php echo(($strType == "quiz") ? "标题" : "用户") ?> </td>
    <?php
      if ($_SESSION["sys"]) {
		?>
    <td background="images/tbg.gif" width="17%" height="20">管理员</td>
    <?php
      }
    ?>
    <td background="images/tbg.gif" width="6%" height="20">最高分</td>
    <td background="images/tbg.gif" width="6%" height="20">最低分</td>
    <td background="images/tbg.gif" width="6%" height="20">平均分</td>
    <td background="images/tbg.gif" width="7%" height="20">数量　</td>
    <td background="images/tbg.gif" width="7%" height="20">及格数 </td>
    <td background="images/tbg.gif" width="7%" height="20">不及格数 </td>
    <td background="images/tbg.gif" width="6%" height="20">图表 </td>
  </tr>
  <form name="frmQuiz" method="POST" action="stat.php?del=true">
  <?php
		$rs = mysql_query($strSql, $conn);
		$num = mysql_num_rows($rs);
		mysql_free_result($rs);
	  $pageSize = 16;
		$pageCount = ceil($num / $pageSize);
		if ($strPage > $pageCount) {
		  $strPage = $pageCount;
	  }
			
		$start = ($strPage - 1) * $pageSize;
		$strSql .= " LIMIT $start, $pageSize";
		$rs = mysql_query($strSql, $conn);
		if (!$rs) {
		  $pageSize = 0;
		}

		for ($i = 0; $i < $pageSize; $i++) {
			$row = mysql_fetch_array($rs, MYSQL_ASSOC);
			if (!$row) {
			  break;
		  }
			
			$recNo = $pageSize * ($strPage - 1) + $i + 1;
      $st = $row[$strSort];
  ?>
  <tr <?php if ($i % 2 != 0) { ?> bgcolor="#E0E0E0"<?php } ?>>
    <td height="20"><?php echo($recNo) ?>　</td>
    <td height="20"><a href="ques.php?sort=<?php echo(urlencode($st)."&admin=".$row['regMail']."&type=".$strType) ?>" title="点击查看详细信息" target="_blank"><?php echo($st) ?></a></td>
    <?php
      if ($_SESSION["sys"]) {
		?>
    <td width="15%" height="20"><?php echo($row['regMail']) ?>　</td>
    <?php
      }
    ?>
    <td height="20"><a href="ques.php?sort=<?php echo(urlencode($st)."&admin=".$row['regMail']."&type=".$strType."&score=".$row['maxScore']) ?>" title="点击查看最高分记录" target="_blank"><?php echo($row['maxScore']) ?></a>　</td>
    <td height="20"><a href="ques.php?sort=<?php echo(urlencode($st)."&admin=".$row['regMail']."&type=".$strType."&score=".$row['minScore']) ?>" title="点击查看最低分记录" target="_blank"><?php echo($row['minScore']) ?></a>　</td>
    <td height="20"><?php echo($row['avgScore']) ?>　</td>
    <td height="20"><?php echo($row['quizCount']) ?>　</td>
    <td height="20"><a href="ques.php?sort=<?php echo(urlencode($st)."&admin=".$row['regMail']."&type=".$strType."&pass=true") ?>" title="点击查看及格记录" target="_blank"><font color="#008000"><?php echo($row['passCount']) ?></font></a></td>
    <td height="20"><a href="ques.php?sort=<?php echo(urlencode($st)."&admin=".$row['regMail']."&type=".$strType."&fail=true") ?>" title="点击查看不及格记录" target="_blank"><font color="#FF0000"><?php echo($row['failCount']) ?></font></a></td>
    <td height="20"><a href="#" onClick="javascript: showPie(<?php echo($row['passCount'].", ".$row["failCount"].", '".$strType."'".", '".urlencode($st)."', '".$row['regMail']."'") ?>); return false"><img border="0" src="images/chart.gif" align="absbottom" width="15" height="15"></a> </td>
  </tr>
  <?php
    }
  ?>
  </form>
  <tr>
    <td colspan="3" align="left" height="18">
      统计方法：<select size="1" name="cbType" onChange="javascript: window.location.href='stat.php?type=' + this.options[this.selectedIndex].value">
      <option value="quiz" <?php if ($strType == "quiz") { ?>selected<?php } ?>>按试题统计</option>
      <option value="user" <?php if ($strType == "user") { ?>selected<?php } ?>>按用户统计</option>
      </select>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      <font color="#008000">信息数：[<?php echo($num )?>]</font>&nbsp;&nbsp;
      <font color="#008000"><img border="0" src="images/page.gif" align="absbottom">页次：[<?php echo("<font color=\"#FF0000\">".$strPage."</font>/".$pageCount) ?>]
    </td>
    <td colspan="4" align="right" height="18">
      <?php 
			  if ($strPage > 1) {
			?>
      <a href="stat.php?page=1&type=<?php echo($strType) ?>">[首 页]</a>&nbsp;&nbsp;
      <a href="stat.php?page=<?php echo(($strPage - 1)."&type=".$strType) ?>">[上一页]</a>&nbsp;&nbsp;
      <?php
        }
        if ($strPage < $pageCount) {
      ?>
      <a href="stat.php?page=<?php echo(($strPage + 1)."&type=".$strType) ?>">[下一页]</a>&nbsp;&nbsp;
      <a href="stat.php?page=<?php echo(($pageCount)."&type=".$strType) ?>">[末 页]</a>
      <?php
        }
      ?>
    </td>
  </tr>
</table>
</center>

</body>

</html>