<?php
  include_once("conn.php");

  if ($_SESSION["admin"] == "") {
	  goto_url("index.html");
  }

  if ($_SESSION["sys"]) {
    $strSrh = TRUE;
	}
  elseif ($_SESSION["admin"] != "") {
    $strSrh = "userId='".$_SESSION["admin"]."'";
	}
	else {
    $strSrh = FALSE;
  }
	
	$strPage = ($_GET["page"] == 0) ? 1 : $_GET["page"];
  $strInfo = trim($_REQUEST["sinfo"]);
  $strUrl = ($strInfo == "") ? "" : "&sinfo=".urlencode($strInfo);
  
  //ȡ�༭����
  $strId = $_GET["id"];
  if (is_numeric($strId)) {
	  $rs = mysql_query("SELECT * FROM `admin` WHERE ".$strSrh." AND id=".$strId, $conn);
	  $num = mysql_num_rows($rs);
	  if ($num != 0) {
			$row = mysql_fetch_array($rs, MYSQL_ASSOC);
			$strUid = $row["userId"];
			$strPwd = $row["userPwd"];
	  }
    mysql_free_result($rs);
  }
    
  //�༭
  if ($_GET["act"] == "edit") {
    $strPwd = $_POST["userPwd"];
    $strId = $_POST["id"];
		mysql_query("UPDATE `admin` SET `userPwd`='".$strPwd."' WHERE id=".$strId, $conn);
    goto_url("admin.php?page=".$strPage.$strUrl);
  }

  //ɾ��...
  $delStr = Trim($_GET["del"]);
  if (is_numeric($delStr)) {
	  $rs = mysql_query("SELECT `sys` FROM `admin` WHERE id=".$delStr, $conn);
	  $num = mysql_num_rows($rs);
	  if ($num != 0) {
			$row = mysql_fetch_array($rs, MYSQL_ASSOC);
			if ($row["sys"]) {
			  echo "<script language='javascript'>alert('������ɾ��ϵͳ����Ա��'); window.location.href='admin.php'</script>";
			}
	    else {
			  mysql_query("DELETE FROM `admin` WHERE id=".$delStr, $conn);
        goto_url("admin.php?page=".$strPage.$strUrl);
			}
		}
		mysql_free_result($rs);
  }
?>

<html>

<meta http-equiv="Content-Type" content="text/html; charset=gb2312">
<link rel="stylesheet" type="text/css" href="style.css">
<meta name="Keywords" content="������, ��������ʦ, ������µ�������ϵͳ, E-Learning, SCORM">
<title>����Ա��Ϣ</title>
</head>

<body>

<center>
<table border="1" width="100%" cellpadding="0" cellspacing="0" bordercolor="#7F9DB9" style="border-collapse: collapse">
  <tr>
    <td colspan="7" align="center" height="20"><b><font size="3" color="#006699">
    ����Ա��Ϣ</font></b></td>
  </tr>
  <tr>
    <td background="images/tbg.gif" width="5%" height="20">���</td>
    <td background="images/tbg.gif" width="25%" height="20">����Ա�˺�</td>
    <td background="images/tbg.gif" width="19%" height="20">����</td>
    <td background="images/tbg.gif" width="10%" height="20">������������</td>
    <?php
      if ($_SESSION["sys"]) {
    ?>
    <td background="images/tbg.gif" width="10%" height="20">ɾ��<img border="0" src="images/del.gif"></td>
    <?php
      }
    ?>
    <td background="images/tbg.gif" width="10%" height="20">�༭<img border="0" src="images/write.gif"></td>
    <td background="images/tbg.gif" width="20%" height="20">��������</td>
  </tr>
  <?php
    if ($strInfo == "") {
      $strSql = "SELECT * FROM `admin` WHERE ".$strSrh." ORDER BY id DESC";
		}
    else {
      $strSql = "SELECT * FROM `admin` WHERE ".$strSrh." AND `userId` LIKE '%".$strInfo."%' ORDER BY id DESC";
    }
		$rs = mysql_query($strSql, $conn);
		if ($rs) {
		  $num = mysql_num_rows($rs);
		  mysql_free_result($rs);
		}
	  $pageSize = 18;
		$pageCount = ceil($num / $pageSize);
		if ($strPage > $pageCount) {
		  $strPage = $pageCount;
	  }
			
		$start = ($strPage - 1) * $pageSize;
		if ($start < 0) {
		  $start = 0;
  	}
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
		  $strUser = str_replace($strInfo, '<font color="#FF0000">'.$strInfo.'</font>', $row["userId"]);
        
      //���¼����
      if (strtolower($row["userId"]) != "admin") {
			  $rsc = mysql_query("SELECT Count(id) AS recCount FROM `quiz` WHERE regMail='".$row["userId"]."'", $conn);
      }
			else {
			  $rsc = mysql_query("SELECT Count(id) AS recCount FROM `quiz`", $conn);
      }
			if (mysql_num_rows($rsc) != 0) {
			  $rowc = mysql_fetch_array($rsc, MYSQL_ASSOC);
			  $recCount = $rowc["recCount"];
			}
      mysql_free_result($rsc);  
			
      //����������
      if (strtolower($row["userId"]) != "admin") {
			  $rsc = mysql_query("SELECT Count(id) AS recCount FROM `users` WHERE admin='".$row["userId"]."'", $conn);
			}
			else {
			  $rsc = mysql_query("SELECT Count(id) AS recCount FROM `users`", $conn);
			}
			if (mysql_num_rows($rsc) != 0) {
			  $rowc = mysql_fetch_array($rsc, MYSQL_ASSOC);
			  $userCount = $rowc["recCount"];
			}
      mysql_free_result($rsc);  
  ?>
  <tr <?php if ($i % 2 != 0) { ?> bgcolor="#E0E0E0"<?php } ?>>
    <td height="20"><?php echo($recNo) ?>��</td>
    <td height="20"><a href="ques.php?admin=<?php echo(urlencode($row["userId"])) ?>" title="�鿴�˹���Ա�������� [<?php echo($recCount) ?>��]" target="_blank"><?php echo($strUser) ?></a>��</td>
    <td height="20"><?php echo($row["userPwd"]) ?>��</td>
    <td height="20"><a href="users.php?sinfo=<?php echo($row["userId"]) ?>"><?php echo($userCount) ?></a>��</td>
    <?php
      if ($_SESSION["sys"]) {
    ?>
    <td height="20"><a href="admin.php?page=<?php echo($strPage."&del=".$row["id"].$strUrl) ?>" title="ɾ����ǰ��¼" onClick="javascript: <?php if ($row["sys"]) { ?>alert('������ɾ��ϵͳ����Ա��');return false<?php } else { ?>return confirm('��ȷ��ɾ�����ʺ�ô��')<?php } ?>">ɾ��</a> </td>
    <?php
      }
    ?>
    <td height="20"><a href="admin.php?page=<?php echo($strPage."&id=".$row["id"].$strUrl) ?>" title="�༭��ǰ��¼">�༭</a></td>
    <td height="20"><?php echo($row["addDate"]) ?>��</td>
  </tr>
  <?php
    }
      
    if ($_SESSION["sys"]) {
  ?>
  <tr>
    <td colspan="4" align="left" height="18" valign="bottom">
      <font color="#008000">��Ϣ����[<?php echo($num )?>]</font>&nbsp;&nbsp;
      <font color="#008000">
      <img border="0" src="images/page.gif" align="absbottom">ҳ�Σ�[<?php echo("<font color=\"#FF0000\">".$strPage."</font>/".$pageCount) ?>]</font>
    </td>
    <td colspan="3" align="right" height="18" valign="bottom">
      <?php 
			  if ($strPage > 1) {
			?>
      <a href="admin.php?page=1<?php echo($strUrl) ?>">[�� ҳ]</a>&nbsp;&nbsp;
      <a href="admin.php?page=<?php echo(($strPage - 1).$strUrl) ?>">[��һҳ]</a>&nbsp;&nbsp;
      <?php
        }
        if ($strPage < $pageCount) {
      ?>
      <a href="admin.php?page=<?php echo(($strPage + 1).$strUrl) ?>">[��һҳ]</a>&nbsp;&nbsp;
      <a href="admin.php?page=<?php echo($pageCount.$strUrl) ?>">[ĩ ҳ]</a>
      <?php
        }
      ?>
    </td>
  </tr>
  <form name="frmSearch" method="GET" action="admin.php">
  <tr>
    <td colspan="7" align="left">
      <font color="#006699"><b>��������Ҫ�������ʺţ�</b></font>&nbsp;
      <input type="text" name="sinfo" size="32" value="<?php echo($strInfo) ?>" ID=Text1>&nbsp;
      <input type="submit" value="����" ID=Submit1></td>
  </tr>
  <?php
    }
  ?>
  </form>
</table>

<?php
  if ($strId != "") {
?>
<br><br>
<table border="1" width="90%" cellspacing="0" cellpadding="0" style="border-collapse: collapse" bordercolor="#7F9DB9">
  <form name="frmAdd" method="POST" action="?page=<%=strPage%><%=strUrl%>&act=edit" onSubmit="javascript: return checkData()" onReset="javascript: document.all('info').innerHTML = ''; this.userId.focus()">
  <tr>
    <td width="25%" align="right">�ʺţ�&nbsp; </td>
    <td width="75%">
    <input type="input" name="userId" value="<?php echo($strUid) ?>" disabled style="width: 180; height: 20" size="20">&nbsp; <label id="info"></label></td>
  </tr>
  <tr>
    <td width="25%" align="right">���룺&nbsp; </td>
    <td width="75%">
    <input type="input" name="userPwd" value="<?php echo($strPwd) ?>" style="width: 180; height: 20" size="20"></td>
  </tr>
  <tr>
    <td width="25%"></td>
    <td width="75%">
      <input type="submit" value="����" name="btnTurn">&nbsp;&nbsp;&nbsp;
      <input type="reset" value="����" name="btnReset">&nbsp;&nbsp;&nbsp;
      <?php
			  if ($strId != "") {
			?>
        <input type="hidden" name="id" value="<?php echo($strId) ?>">
        <input type="button" value="ȡ��" name="btnCancel" onClick="javascript: window.location.href='admin.php'">
      <?php
			  }
			?>
    </td>
  </tr>
  </form>
</table>
<?php
  }
?>

</body>

</html>