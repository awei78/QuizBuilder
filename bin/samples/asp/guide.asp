<%
  Dim strAdmin
  If Session("Admin") <> "" Then
    strAdmin = Session("Admin")
  Else
    strAdmin = "������"
  End If
%>

<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=gb2312">
<link rel="stylesheet" type="text/css" href="style.css">
<base target="main">
<meta name="Keywords" content="������, ��������ʦ, ������µ�������ϵͳ, E-Learning, SCORM">
<title>����</title>
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
    <td width="100%" height="20" align="center">����Ա��<font color="#FF0000"><%=strAdmin%></font></td>
  </tr>
  <tr>
    <td width="100%" background="images/tbg.gif" height="18" align="center">
      <img id="img0" border="0" src="images/decs.gif" onClick="javascript: display(tr0, img0)" style="cursor: hand"><a href="#" onClick="javascript: display(tr0, img0); return(false)">���Խ��</a>
    </td>
  </tr>
  <tr id="tr0" style="display: block">
    <td height="1">
      <table width="100%" cellspacing="1" border="1" bordercolor="#7F9DB9" style="border-collapse: collapse">
        <tr>
          <td width="100%" height="18" align="center">&nbsp;<a href="quiz.asp">��Ϣ�б�</a></td>
        </tr>
        <tr>
          <td width="100%" height="18" align="center">&nbsp;<a href="stat.asp">��Ϣͳ��</a></td>
        </tr>
      </table>  
    </td>
  </tr>
  <%
    If Session("Admin") <> "" Then
  %>
  <tr>
    <td width="100%" background="images/tbg.gif" height="18" align="center">
      <img id="img1" border="0" src="images/decs.gif" onClick="javascript: display(tr1, img1)" style="cursor: hand"><a href="#" onClick="javascript: display(tr1, img1); return(false)">�û�����</a>
    </td>
  </tr>
  <tr id="tr1" style="display: block">
    <td height="1">
      <table width="100%" cellspacing="1" border="1" bordercolor="#7F9DB9" style="border-collapse: collapse">
        <tr>
          <td width="100%" height="18" align="center"><a href="admin.asp">�� �� Ա</a></td>
        </tr>
        <tr>
          <td width="100%" height="18" align="center"><a href="users.asp">�û���Ϣ</a></td>
        </tr>
      </table>  
    </td>
  </tr>
  <%
      If Session("Sys") Then
  %>
  <tr>
    <td width="100%" height="18" align="center"><a href="addata.asp">���ݿ����</a></td>
  </tr>
  <%
      End If
    End If
  %>
  <tr>
    <td width="100%" height="18" align="center"><a href="exit.asp" target="_parent">[�˳�ϵͳ]</a></td>
  </tr>
</table>

</body>

</html>