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
	
  //�ݵ�¼����Ա���ò�ѯ
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
<meta name="Keywords" content="������, ��������ʦ, ������µ�������ϵͳ, E-Learning, SCORM">
<title>��������ʦ���ݹ���ϵͳ - ������Ϣͳ��</title>
<script language="javascript">
<!--
  function showPie(p, f, t, u, admin) {
    if (window.navigator.userAgent.indexOf("MSIE") >= 1) { 
			var w = window.open("pie.php?p="+ p +"&f="+ f + "&t=" + t + "&u=" + u + "&a=" + admin, "ͼ����ʾ", "height=445, width=625, toolbar=no, menubar=no, scrollbars=no, resizable=no,location=no, status=no"); 
      w.focus();
    }
    else {
      alert("������������ǻ���IE�����������֧��ͼ����ʾ���ܡ�");
    }
  }
-->
</script>

</head>

<body onLoad="javascript: document.all.cbType.focus()">

<center>
<table border="1" width="100%" cellpadding="0" cellspacing="0" bordercolor="#7F9DB9" style="border-collapse: collapse">
  <tr>
    <td colspan="10" align="center" height="20"><b><font size="3" color="#006699">������Ϣͳ��</font></b></td>
  </tr>
  <tr>
    <td background="images/tbg.gif" width="4%" height="20">��� </td>
    <td background="images/tbg.gif" width="34%" height="20"><?php echo(($strType == "quiz") ? "����" : "�û�") ?> </td>
    <?php
      if ($_SESSION["sys"]) {
		?>
    <td background="images/tbg.gif" width="17%" height="20">����Ա</td>
    <?php
      }
    ?>
    <td background="images/tbg.gif" width="6%" height="20">��߷�</td>
    <td background="images/tbg.gif" width="6%" height="20">��ͷ�</td>
    <td background="images/tbg.gif" width="6%" height="20">ƽ����</td>
    <td background="images/tbg.gif" width="7%" height="20">������</td>
    <td background="images/tbg.gif" width="7%" height="20">������ </td>
    <td background="images/tbg.gif" width="7%" height="20">�������� </td>
    <td background="images/tbg.gif" width="6%" height="20">ͼ�� </td>
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
    <td height="20"><?php echo($recNo) ?>��</td>
    <td height="20"><a href="ques.php?sort=<?php echo(urlencode($st)."&admin=".$row['regMail']."&type=".$strType) ?>" title="����鿴��ϸ��Ϣ" target="_blank"><?php echo($st) ?></a></td>
    <?php
      if ($_SESSION["sys"]) {
		?>
    <td width="15%" height="20"><?php echo($row['regMail']) ?>��</td>
    <?php
      }
    ?>
    <td height="20"><a href="ques.php?sort=<?php echo(urlencode($st)."&admin=".$row['regMail']."&type=".$strType."&score=".$row['maxScore']) ?>" title="����鿴��߷ּ�¼" target="_blank"><?php echo($row['maxScore']) ?></a>��</td>
    <td height="20"><a href="ques.php?sort=<?php echo(urlencode($st)."&admin=".$row['regMail']."&type=".$strType."&score=".$row['minScore']) ?>" title="����鿴��ͷּ�¼" target="_blank"><?php echo($row['minScore']) ?></a>��</td>
    <td height="20"><?php echo($row['avgScore']) ?>��</td>
    <td height="20"><?php echo($row['quizCount']) ?>��</td>
    <td height="20"><a href="ques.php?sort=<?php echo(urlencode($st)."&admin=".$row['regMail']."&type=".$strType."&pass=true") ?>" title="����鿴�����¼" target="_blank"><font color="#008000"><?php echo($row['passCount']) ?></font></a></td>
    <td height="20"><a href="ques.php?sort=<?php echo(urlencode($st)."&admin=".$row['regMail']."&type=".$strType."&fail=true") ?>" title="����鿴�������¼" target="_blank"><font color="#FF0000"><?php echo($row['failCount']) ?></font></a></td>
    <td height="20"><a href="#" onClick="javascript: showPie(<?php echo($row['passCount'].", ".$row["failCount"].", '".$strType."'".", '".urlencode($st)."', '".$row['regMail']."'") ?>); return false"><img border="0" src="images/chart.gif" align="absbottom" width="15" height="15"></a> </td>
  </tr>
  <?php
    }
  ?>
  </form>
  <tr>
    <td colspan="3" align="left" height="18">
      ͳ�Ʒ�����<select size="1" name="cbType" onChange="javascript: window.location.href='stat.php?type=' + this.options[this.selectedIndex].value">
      <option value="quiz" <?php if ($strType == "quiz") { ?>selected<?php } ?>>������ͳ��</option>
      <option value="user" <?php if ($strType == "user") { ?>selected<?php } ?>>���û�ͳ��</option>
      </select>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      <font color="#008000">��Ϣ����[<?php echo($num )?>]</font>&nbsp;&nbsp;
      <font color="#008000"><img border="0" src="images/page.gif" align="absbottom">ҳ�Σ�[<?php echo("<font color=\"#FF0000\">".$strPage."</font>/".$pageCount) ?>]
    </td>
    <td colspan="4" align="right" height="18">
      <?php 
			  if ($strPage > 1) {
			?>
      <a href="stat.php?page=1&type=<?php echo($strType) ?>">[�� ҳ]</a>&nbsp;&nbsp;
      <a href="stat.php?page=<?php echo(($strPage - 1)."&type=".$strType) ?>">[��һҳ]</a>&nbsp;&nbsp;
      <?php
        }
        if ($strPage < $pageCount) {
      ?>
      <a href="stat.php?page=<?php echo(($strPage + 1)."&type=".$strType) ?>">[��һҳ]</a>&nbsp;&nbsp;
      <a href="stat.php?page=<?php echo(($pageCount)."&type=".$strType) ?>">[ĩ ҳ]</a>
      <?php
        }
      ?>
    </td>
  </tr>
</table>
</center>

</body>

</html>