<?php
  include_once("conn.php");

  //�ݵ�¼����Ա���ò�ѯ
	if ($_SESSION["sys"]) {
	  $strSrh = TRUE;
	}
	elseif ($_SESSION["admin"] != "") {
	  $strSrh = "regMail='".$_SESSION["admin"]."'";
	}
	else {
	  $strSrh = "regMail=''";
	}
	
	$strPage = ($_GET["page"] == 0) ? 1 : $_GET["page"];
  $strInfo = trim($_REQUEST["info"]);
  $strUrl = ($strInfo == "") ? "" : "&info=".urlencode($strInfo);

  //ɾ������...
  $delStr = trim($_REQUEST["del"]);
	//ɾ��������¼
  if (is_numeric($delStr)) { 
	  mysql_query("DELETE FROM `quiz` WHERE `id`='".$delStr."'", $conn);
	  goto_url("quiz.php?page=".$strPage.$strUrl);
  }
	//ɾ��������¼
  elseif ($delStr == "true") {
	  $delIds = implode(",", $_REQUEST["quiz"]);
	  mysql_query("DELETE FROM `quiz` WHERE `id` IN (".$delIds.")", $conn);
		goto_url("quiz.php");
  }
	//��ռ�¼
  elseif ($delStr == "all") {
	  if ($strInfo == "") {
      mysql_query("DELETE FROM `quiz` WHERE ".$strSrh, $conn);
	  } 
	  else {
	    mysql_query("DELETE FROM `quiz` WHERE ".$strSrh." AND `quizTitle` LIKE '%".$strInfo."%' or `userId` LIKE '".$strInfo."'", $conn);
	  }
    goto_url("quiz.php");
  }
?>
<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=gb2312">
<link rel="stylesheet" type="text/css" href="style.css">
<meta name="Keywords" content="������, ��������ʦ, ������µ�������ϵͳ, E-Learning, SCORM">
<title>��������ʦ���ݹ���ϵͳ - ������Ϣ����</title>

<script type="text/javascript">
<!--
	function checkAll(form) {
		form.elements("chkAll").title =form.elements("chkAll").checked ? 'ȡ��ѡ��' : 'ȫ��ѡ��';
		for(var i = 0; i < form.elements.length; i++) {
			var e = form.elements[i];
			if(e.type=="checkbox" && e.name == "quiz[]") {
				e.checked = form.elements("chkAll").checked;;
			}
		}
	}
 
  function delAll() {
    var hasChecked = false;
    for (var i = 0; i <= document.getElementsByName('quiz[]').length - 1; i++) {
      if (document.getElementsByName('quiz[]')[i].checked) {
        hasChecked = true;
        break;
      }
    }
		
	  if (!hasChecked) {
      alert('��ѡ��Ҫɾ������Ϣ��');
    }  
    else if (confirm('��ȷ��Ҫɾ����ѡ�����Ϣ��')) {
      document.frmQuiz.submit(); 
    } 
  }
  
  function clearAll() {
    if (confirm('��ȷ��Ҫ������м�¼��')) {
      window.location.href = "quiz.php?del=all&info=<?php echo(urlencode($strInfo)) ?>";
    }  
  }
-->
</script>
</head>

<body>

<center>
<table border="1" width="100%" cellpadding="0" cellspacing="0" bordercolor="#7F9DB9" style="border-collapse: collapse">
  <tr>
    <td colspan="11" align="center" height="20"><b><font size="3" color="#006699">������Ϣ����</font></b></td>
  </tr>
  <form name="frmQuiz" method="POST" action="quiz.php?del=true">
  <tr>
    <td background="images/tbg.gif" width="4%"><input type="checkbox" name="chkAll" value="1" title="ȫ��ѡ��" onClick="javascript: checkAll(this.form)" style="cursor: hand"></td>
    <td background="images/tbg.gif" width="4%">��� </td>
    <td background="images/tbg.gif" width="28%">���� </td>
    <td background="images/tbg.gif" width="8%">������ </td>
    <?php
      if ($_SESSION["sys"]) {
    ?>
    <td background="images/tbg.gif" width="14%">����Ա��</td>
    <?php
      }
    ?>
    <td background="images/tbg.gif" width="4%">�÷� </td>
    <td background="images/tbg.gif" width="4%">�ܷ� </td>
    <td background="images/tbg.gif" width="5%">����� </td>
    <td background="images/tbg.gif" width="7%">�Ƿ�ͨ�� </td>
    <td background="images/tbg.gif" width="4%">ɾ�� </td>
    <td background="images/tbg.gif" width="18%">�ύ���� </td>
  </tr>
  <?php
		if ($strInfo == "") { 
			$sql = "SELECT * FROM `quiz` WHERE ".$strSrh;
		}
		else {
			$sql = "SELECT * FROM `quiz` WHERE ".$strSrh." AND (`quizTitle` LIKE '%".$strInfo."%' OR `userId` LIKE '%".$strInfo."%')";
		}
		$rs = mysql_query($sql, $conn);
		$num = mysql_num_rows($rs);
		mysql_free_result($rs);
	  $pageSize = PAGE_SIZE;
		$pageCount = ceil($num / $pageSize);
		if ($strPage > $pageCount) {
		  $strPage = $pageCount;
	  }
			
		$start = ($strPage - 1) * $pageSize;
 		$sql .= " ORDER BY `id` DESC LIMIT $start, $pageSize";
		$rs = mysql_query($sql, $conn);
		if (!$rs) {
		  $pageSize = 0;
		}

		for ($i = 0; $i < $pageSize; $i++) {
			$row = mysql_fetch_array($rs, MYSQL_ASSOC);
			if (!$row) {
			  break;
		  }
			
			$recNo = $pageSize * ($strPage - 1) + $i + 1;
  ?>
  <tr <?php if ($i % 2 != 0) { ?> bgcolor="#E0E0E0"<?php } ?>>
    <td><input type="checkbox" name="quiz[]" value="<?php echo($row['id'])?>"> </td>
    <td><?php if($row['passState']) echo("<span style=\"color:#080\">".$recNo."</span>");else echo("<span style=\"color:#F00\">".$recNo."</span>")?> </td>
		<td><a href="show.php?id=<?php echo($row['id'])?>"  title="����鿴��ϸ��Ϣ" target="_blank"><?php echo(str_replace($strInfo, "<span style=\"color:#F00\">$strInfo</span>", $row['quizTitle']))?></a> </td>
    <td><a href="mailto:<?php echo($row['userMail'])?>" title="�����ʼ��� <?php echo($row['userId'])?>"><?php echo(str_replace($strInfo, "<span style=\"color:#F00\">$strInfo</span>", $row['userId']))?></a> </td>
    <?php
      if ($_SESSION["sys"]) {
    ?>
    <td><?php echo($row['regMail'])?> </td>
    <?php
      }
    ?>
    <td><?php echo($row['userScore'])?> </td>
    <td><?php echo($row['totalScore'])?> </td>
    <td><?php echo($row['passScore'])?> </td>
    <td><?php if ($row['passState']) echo("<span style=\"color:#080\">��</span>"); else echo("<span style=\"color:#F00\">��</span>")?> </td>
    <td><a href="quiz.php?del=<?php echo($row['id'])?>&page=<?php echo($strPage )?><?php echo($strUrl)?>" title="ɾ��������¼" onClick="javascript: return confirm('��ȷ��ɾ���˼�¼ô��')">ɾ��</a> </td>
    <td><?php echo($row['addDate'])?> </td>
  </tr>
  <?php
	  }
  ?>
  </form>
  <tr>
    <td colspan="7" align="left" height="18">
      <a href="#" onClick="javascript: delAll()">[�����ѡ��ļ�¼]</a>&nbsp;&nbsp;&nbsp;
      <img border="0" src="images/del.gif" align="absbottom"><a href="#" onClick="javascript: clearAll()">[������м�¼]</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      <font color="#008000">��Ϣ����[<?php echo($num )?>]</font>&nbsp;&nbsp;
      <font color="#008000"><img border="0" src="images/page.gif" align="absbottom">ҳ�Σ�[<?php echo("<font color=\"#FF0000\">".$strPage."</font>/".$pageCount) ?>]
    </td>
    <td colspan="4" align="right" height="18">
      <?php 
			  if ($strPage > 1) {
			?>
      <a href="quiz.php?page=1<?php echo($strUrl)?>">[�� ҳ]</a>&nbsp;&nbsp;
      <a href="quiz.php?page=<?php echo(($strPage-1).$strUrl)?>">[��һҳ]</a>&nbsp;&nbsp;
      <?php
        }
        if ($strPage < $pageCount) {
      ?>
      <a href="quiz.php?page=<?php echo(($strPage + 1).$strUrl)?>">[��һҳ]</a>&nbsp;&nbsp;
      <a href="quiz.php?page=<?php echo(($pageCount).$strUrl)?>">[ĩ ҳ]</a>
      <?php
        }
      ?>
    </td>
  </tr>
  <form name="frmSearch" method="GET" action="quiz.php">
  <tr>
    <td colspan="11">
      <font color="#006699"><b>�����������������ʺ�������</b></font>&nbsp;
      <input type="text" name="info" size="35" value="<?php echo($strInfo)?>">&nbsp;
      <input type="submit" value="����" name="btnSrh"></td>
  </tr>
  </form>
</table>
</center>

</body>

</html>