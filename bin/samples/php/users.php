<?php
  include_once("conn.php");

  if ($_SESSION["admin"] == "") {
	  goto_url("index.html");
  }

  //�ݵ�¼����Ա���ò�ѯ
  if ($_SESSION["sys"]) {
    $strSrh = TRUE;
	}
  elseif ($_SESSION["admin"] != "") {
    $strSrh = "admin='".$_SESSION["admin"]."'";
	}
  else {
    $strSrh = "admin=''";
  }
  
  $strPage = ($_GET["page"] == 0) ? 1 : $_GET["page"];
  $strInfo = trim($_REQUEST["sinfo"]);
  $strUrl = ($strInfo == "") ? "" : "&sinfo=".urlencode($strInfo);
  
  //�������������...
  //����
  if ($_GET["u"] != "") {
	  mysql_query("UPDATE `users` SET `inUse`=TRUE WHERE id=".$_GET["u"], $conn);
  }
  //����
  if ($_GET["r"] != "") {
    mysql_query("UPDATE `users` SET `inUse`=FALSE WHERE id=".$_GET["r"], $conn);
  }
  
  //ȡ�༭����
  $strId = $_GET["id"];
  if (is_numeric($strId)) {
    $rs = mysql_query("SELECT * FROM `users` WHERE ".$strSrh." AND id=".$strId, $conn);
	  $num = mysql_num_rows($rs);
	  if ($num != 0) {
			$row = mysql_fetch_array($rs, MYSQL_ASSOC);
			$strUid = $row["userId"];
			$strPwd = $row["userPwd"];
			$strMail = $row["userMail"];
			$inUse = $row["inUse"];
	  }
    mysql_free_result($rs);	
  }
    
  $strAct = $_GET["act"];
  //���
  if ($strAct == "add") {
    $strUid = $_POST["userId"];
		$rs = mysql_query("SELECT id FROM `users` WHERE ".$strSrh." AND userId='".$strUid."'", $conn);
    
    if (mysql_num_rows($rs) != 0) {
      echo "<script language='javascript'>alert('��Ҫ��ӵ��ʺ� [".$strUid."] �Ѵ��ڣ�'); window.location.href='users.php'</script>";
		}
		else {
      $strPwd = $_POST["userPwd"];
      $strMail = $_POST["userMail"];
      $inUse = $_POST["cbUse"]."";
      if ($inUse == "") {
			  $inUse = "False";
			}
      mysql_query("INSERT INTO `users`(`userId`, `userPwd`, `userMail`, `admin`, `inUse`) VALUES('".$strUid."', '".$strPwd."', '".$strMail."', '".$_SESSION["admin"]."', ".$inUse.")", $conn);
      
      goto_url("users.php?page=".strPage.strUrl);
    }
		mysql_free_result($rs);	
  }
  
  //�༭
  if ($strAct == "edit") {
    $strUid = str_replace("'", "''", $_POST["userId"]);
    $strId = $_POST["id"];
		$rs = mysql_query("SELECT id FROM `users` WHERE ".$strSrh." AND userId='".$strUid."' AND `id`<>".$strId, $conn);
    
    if (mysql_num_rows($rs) != 0) {
      echo "<script language='javascript'>alert('��Ҫ���µ��ʺ� [".$strUid."] �Ѵ��ڣ�'); window.history.back()</script>";
		}
		else {
      $strPwd = $_POST["userPwd"];
      $strMail = $_POST["userMail"];
      $inUse = $_POST["cbUse"]."";
      if ($inUse == "") {
			  $inUse = "False";
			}
			mysql_query("UPDATE `users` SET `userId`='".$strUid."', `userPwd`='".$strPwd."', `userMail`='".$strMail."', `inUse`=".$inUse." WHERE `id`=".$strId, $conn);
      
      goto_url("users.php?page=".$strPage.$strUrl);
    }
    mysql_free_result($rs);	
  }

  //ɾ��.
  $delStr = trim($_GET["del"]);
  //ɾ��������¼
  if (is_numeric($delStr)) {
  	mysql_query("DELETE FROM `users` WHERE `id`=".$delStr, $conn);
    goto_url("users.php?page=".$strPage.$strUrl);
	}
  //ɾ����ѡ���¼      
  elseif ($delStr == "true") {
	  $delIds = implode(",", $_REQUEST["id"]);
	  mysql_query("DELETE FROM `users` WHERE `id` IN (".$delIds.")", $conn);
		goto_url("users.php");
	}
  //��ռ�¼  
  elseIf ($delStr == "all") {
    if ($strInfo == "") {
		  mysql_query("DELETE FROM `users` WHERE ".$strSrh, $conn);
		}
		else {
		  mysql_query("DELETE FROM `users` WHERE ".$strSrh." AND `userId` LIKE '%".$strInfo."%'", $conn);
    }
    goto_url("users.php");
  }
?>

<html>

<meta http-equiv="Content-Type" content="text/html; charset=gb2312">
<link rel="stylesheet" type="text/css" href="style.css">
<meta name="Keywords" content="������, ��������ʦ, ������µ�������ϵͳ, E-Learning, SCORM">
<title>�û���Ϣ����</title>

<script language="javascript">
<!--
  function checkData() {
    if (document.frmAdd.userId.value == "") {
      document.all('info').innerHTML = '<font color="#FF0000">��������Ҫ��ӵ��ʺţ�</font>';
      document.frmAdd.userId.focus();
      return false;
    }
    
    return true;
  }
  
	function checkAll(form) {
		form.elements("chkAll").title =form.elements("chkAll").checked ? 'ȡ��ѡ��' : 'ȫ��ѡ��';
		for(var i = 0; i < form.elements.length; i++) {
			var e = form.elements[i];
			if(e.type=="checkbox" && e.name == "id[]") {
				e.checked = form.elements("chkAll").checked;;
			}
		}
	}
  
  function delAll() {
    var hasChecked = false;
    for (var i = 0; i <= document.getElementsByName('id[]').length - 1; i++) {
      if (document.getElementsByName('id[]')[i].checked) {
        hasChecked = true;
        break;
      }
    }
		
	  if (!hasChecked) {
      alert('��ѡ��Ҫɾ�����˺ţ�');
    }  
    else if (confirm('��ȷ��Ҫɾ����ѡ����ʺ���')) {
      document.frmUser.submit(); 
    } 
  }
  
  function clearAll() {
    if (confirm('��ȷ��Ҫ������м�¼��')) {
      window.location.href = 'users.php?del=all&sinfo=<?php echo(urlencode($strInfo)) ?>';
    }
  }
-->
</script>
</head>

<body>

<center>
<table border="1" width="100%" cellpadding="0" cellspacing="0" bordercolor="#7F9DB9" style="border-collapse: collapse">
  <tr>
    <td colspan="10" align="center" height="20"><b><font size="3" color="#006699">
    �û���Ϣ����</font></b></td>
  </tr>
  <form name="frmUser" method="POST" action="?del=true<?php echo($strUrl) ?>">
  <tr>
    <td background="images/tbg.gif" width="4%"><input type="checkbox" name="chkAll" value="1" title="ȫ��ѡ��" onClick="javascript: checkAll(this.form)" style="cursor: hand"></td>
    <td background="images/tbg.gif" width="4%">���</td>
    <td background="images/tbg.gif" width="15%">�û��˺�</td>
    <td background="images/tbg.gif" width="10%">����</td>
    <td background="images/tbg.gif" width="14%">�ʼ�</td>
    <?php
      if ($_SESSION["sys"]) {
    ?>
    <td background="images/tbg.gif" width="15%">����Ա</td>
    <?php
      }
    ?>
    <td background="images/tbg.gif" width="8%">���ü��</td>
    <td background="images/tbg.gif" width="6%">ɾ��<img border="0" src="images/del.gif"></td>
    <td background="images/tbg.gif" width="6%">�༭<img border="0" src="images/write.gif"></td>
    <td background="images/tbg.gif" width="18%">��������</td>
  </tr>
  <?php
	  if ($strInfo == "" || strtolower($strInfo) == "admin") {
		  $strSql = "SELECT *, (SELECT Count(id) FROM `quiz` WHERE userId=users.userId) as `recCount` FROM `users` WHERE ".$strSrh;
		}
		else {
      $strSql = "SELECT *, (SELECT Count(id) FROM `quiz` WHERE userId=users.userId) as `recCount` FROM `users` WHERE ".$strSrh." AND (userId LIKE '%".$strInfo."%' OR admin LIKE '%".$strInfo."%')";		
  	}
		$rs = mysql_query($strSql, $conn);
		$num = mysql_num_rows($rs);
		mysql_free_result($rs);
	  $pageSize = 18;
		$pageCount = ceil($num / $pageSize);
		if ($strPage > $pageCount) {
		  $strPage = $pageCount;
	  }
			
		$start = ($strPage - 1) * $pageSize;
		$strSql .= " ORDER BY `id` DESC LIMIT $start, $pageSize";
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
			$strUser = str_replace($strInfo, "<font color=\"#FF0000\">".$strInfo."</font>", $row["userId"]);
  ?>
  <tr <?php if ($i % 2 != 0) { ?> bgcolor="#E0E0E0"<?php } ?>>
    <td><input type="checkbox" name="id[]" value="<?php echo($row["id"]) ?>"></td>
    <td><?php echo($recNo) ?>��</td>
    <td><a href="ques.php?user=<?php echo(urlencode($row["userId"])) ?>" title="�鿴���û��������� [<?php echo($row["recCount"]) ?>��]" target="_blank"><?php echo($strUser) ?></a>��</td>
    <td><?php echo($row["userPwd"]) ?>��</td>
    <td><a href="mailto:<?php echo($row["userMail"]) ?>" title="�����ʼ���<?php echo($row["userMail"]) ?>"><?php echo($row["userMail"]) ?></a>��</td>
    <?php
      if ($_SESSION["sys"]) {
    ?>
    <td><?php echo(str_replace($strInfo, "<font color=\"#FF0000\">".$strInfo."</font>", $row["admin"])) ?> </td>
    <?php
      }
    ?>
    <td>
    <?php
      if ($row["inUse"]) {
        echo "<a href=\"users.php?page=".$strPage.$strUrl."&r=".$row["id"]."\" title=\"���õ�ǰ�˺ŵ������⹦��\"><font color=\"#FF0000\">����</font></a>";
      }
			else {
        echo "<a href=\"users.php?page=".$strPage.$strUrl."&u=".$row["id"]."\" title=\"���õ�ǰ�˺ŵ������⹦��\"><font color=\"#008000\">����</font></a>";
      }
    ?> ��
    </td>
    <td><a href="users.php?page=<?php echo($strPage."&del=".$row["id"].$strUrl) ?>" title="ɾ����ǰ��¼" onClick="javascript: return confirm('��ȷ��ɾ�����ʺ�ô��')">ɾ��</a> </td>
    <td><a href="users.php?page=<?php echo($strPage."&id=".$row["id"].$strUrl) ?>" title="�༭��ǰ��¼">�༭</a></td>
    <td><?php echo($row["addDate"]) ?>��</td>
  </tr>
  <?php
    }
  ?>
  <tr>
    <td colspan="6" align="left" height="18" valign="bottom">
      <a href="#" onClick="javascript: delAll()">[�����ѡ��ļ�¼]</a>&nbsp;&nbsp;&nbsp;
      <img border="0" src="images/del.gif" align="absbottom"><a href="#" onClick="javascript: clearAll()">[������м�¼]</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      <font color="#008000">��Ϣ����[<?php echo($num )?>]</font>&nbsp;&nbsp;
      <font color="#008000">
      <img border="0" src="images/page.gif" align="absbottom">ҳ�Σ�[<?php echo("<font color=\"#FF0000\">".$strPage."</font>/".$pageCount) ?>]</font>
    </td>
    <td colspan="4" align="right" height="18" valign="bottom">
      <?php 
			  if ($strPage > 1) {
			?>
      <a href="users.php?page=1<?php echo($strUrl) ?>">[�� ҳ]</a>&nbsp;&nbsp;&nbsp;
      <a href="users.php?page=<?php echo(($strPage - 1).$strUrl) ?>">[��һҳ]</a>&nbsp;&nbsp;&nbsp;
      <?php
        }
        if ($strPage < $pageCount) {
      ?>
      <a href="users.php?page=<?php echo(($strPage + 1).$strUrl) ?>">[��һҳ]</a>&nbsp;&nbsp;&nbsp;
      <a href="users.php?page=<?php echo($pageCount.$strUrl) ?>">[ĩ ҳ]</a>
      <?php
        }
      ?>
    </td>
  </tr>
  </form>
  <form name="frmSearch" method="GET" action="users.php">
  <tr>
    <td colspan="10" align="left">
      <font color="#006699"><b>��������Ҫ�������ʺţ�</b></font>&nbsp;
      <input type="text" name="sinfo" size="32" value="<?php echo($strInfo) ?>">&nbsp;
      <input type="submit" value="����"></td>
  </tr>
  </form>
</table>

<br><br>
<?php
  if ($strId != "") {
    $strAct = "edit";
    $strCap = "����";
	}
	else {
    $strAct = "add";
    $strCap = "���";
  }
?>
<table border="1" width="90%" cellspacing="0" cellpadding="0" style="border-collapse: collapse" bordercolor="#7F9DB9">
  <form name="frmAdd" method="POST" action="?page=<?php echo($strPage.$strUrl."&act=".$strAct) ?>" onSubmit="javascript: return checkData()" onReset="javascript: document.all('info').innerHTML = ''; this.userId.focus()">
  <tr>
    <td width="25%" align="right">��</td>
    <td width="75%"><b><font size="2" color="#006699"><?php echo($strCap) ?>�ʺ�</font></b>��</td>
  </tr>
  <tr>
    <td width="25%" align="right">�ʺţ�&nbsp; </td>
    <td width="75%">
    <input type="input" name="userId" value="<?php echo($strUid) ?>" style="width: 180; height: 20" size="20">&nbsp; <label id="info"></label></td>
  </tr>
  <tr>
    <td width="25%" align="right">���룺&nbsp; </td>
    <td width="75%">
    <input type="input" name="userPwd" value="<?php echo($strPwd) ?>" style="width: 180; height: 20" size="20"></td>
  </tr>
  <tr>
    <td width="25%" align="right">�ʼ���&nbsp; </td>
    <td width="75%">
    <input type="input" name="userMail" value="<?php echo($strMail) ?>" style="width: 180; height: 20" size="20"></td>
  </tr>
  <tr>
    <td width="25%" align="right">���ü�⣺&nbsp; </td>
    <td width="75%"><input type="checkbox" name="cbUse" value="True" <?php if ($inUse || $strId == "") { ?>checked<?php } ?>>&nbsp; 
    <font color="#0000FF">(�˴����ã���Ӧ�����ʦ��������֮<font color="#FF6600">[���Ᵽ��]</font>-><font color="#FF6600">[���뱣��]</font>-><font color="#FF6600">[��ҳ��֤]</font>֮ѡ��)</font></td>
  </tr>
  <tr>
    <td width="25%"></td>
    <td width="75%">
      <input type="submit" value="<?php echo($strCap) ?>" name="btnTurn">&nbsp;&nbsp;&nbsp;
      <input type="reset" value="����" name="btnReset">&nbsp;&nbsp;&nbsp;
      <?php
			  if ($strId != "") {
			?>
        <input type="hidden" name="id" value="<?php echo($strId) ?>">
        <input type="button" value="ȡ��" name="btnCancel" onClick="javascript: window.location.href='users.php'">
      <?php
			  }
			?>
    </td>
  </tr>
  </form>
</table>

</body>

</html>