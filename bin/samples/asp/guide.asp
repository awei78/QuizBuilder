<%
  Dim strAdmin
  If Session("Admin") <> "" Then
    strAdmin = Session("Admin")
  Else
    strAdmin = "测试者"
  End If
%>

<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=gb2312">
<link rel="stylesheet" type="text/css" href="style.css">
<base target="main">
<meta name="Keywords" content="秋风软件, 秋风试题大师, 秋风人事档案管理系统, E-Learning, SCORM">
<title>导航</title>
<script type="text/javascript">
<!--
  function display(tr, img) {
    tr.style.display = (tr.style.display == "none") ? "block" : "none";
    img.src = (tr.style.display == "none") ? "images/plus.gif" : "images/decs.gif";
  }
//-->
</script>
</head>

<body topmargin="0" leftmargin="0" background="images/bg.gif">
<table border="1" width="100%" cellspacing="0" cellpadding="0" bordercolor="#7F9DB9" style="border-collapse: collapse">
  <tr>
    <td width="100%" height="20" align="center">管理员：<font color="#FF0000"><%=strAdmin%></font></td>
  </tr>
  <tr>
    <td width="100%" background="images/tbg.gif" height="18" align="center">
      <img id="img0" border="0" src="images/decs.gif" onClick="javascript: display(tr0, img0)" style="cursor: hand"><a href="#" onClick="javascript: display(tr0, img0); return(false)">测试结果</a>
    </td>
  </tr>
  <tr id="tr0" style="display: block">
    <td height="1">
      <table width="100%" cellspacing="1" border="1" bordercolor="#7F9DB9" style="border-collapse: collapse">
        <tr>
          <td width="100%" height="18" align="center">&nbsp;<a href="quiz.asp">信息列表</a></td>
        </tr>
        <tr>
          <td width="100%" height="18" align="center">&nbsp;<a href="stat.asp">信息统计</a></td>
        </tr>
      </table>  
    </td>
  </tr>
  <%
    If Session("Admin") <> "" Then
  %>
  <tr>
    <td width="100%" background="images/tbg.gif" height="18" align="center">
      <img id="img1" border="0" src="images/decs.gif" onClick="javascript: display(tr1, img1)" style="cursor: hand"><a href="#" onClick="javascript: display(tr1, img1); return(false)">用户管理</a>
    </td>
  </tr>
  <tr id="tr1" style="display: block">
    <td height="1">
      <table width="100%" cellspacing="1" border="1" bordercolor="#7F9DB9" style="border-collapse: collapse">
        <tr>
          <td width="100%" height="18" align="center"><a href="admin.asp">管 理 员</a></td>
        </tr>
        <tr>
          <td width="100%" height="18" align="center"><a href="users.asp">用户信息</a></td>
        </tr>
      </table>  
    </td>
  </tr>
  <%
      If Session("Sys") Then
  %>
  <tr>
    <td width="100%" height="18" align="center"><a href="addata.asp">数据库管理</a></td>
  </tr>
  <%
      End If
    End If
  %>
  <tr>
    <td width="100%" height="18" align="center"><a href="exit.asp" target="_parent">[退出系统]</a></td>
  </tr>
</table>

</body>

</html>