<!-- #include file="conn.asp" -->
<!-- #include file="fso.asp" -->

<%
  Dim i, strSql, strType, strSort, strPage
  strType = Request.QueryString("type")&""
  If strType = "" Then strType = "quiz"
  If strType = "quiz" Then
    strSort= "quizTitle"
  Else
    strSort= "userId"
  End If
  
  strPage = Request.QueryString("page")&""
  If strPage = "" Then strPage = "0"
  
  '�ݵ�¼����Ա���ò�ѯ
  strSql = "SELECT "& strSort &", regMail, " &_
    "(SELECT Max(userScore) FROM [quiz] WHERE "& strSort &"=a."& strSort &" AND regMail=a.regMail) AS maxScore, " &_
    "(SELECT Min(userScore) FROM [quiz] WHERE "& strSort &"=a."& strSort &" AND regMail=a.regMail) AS minScore, " &_
    "(SELECT Avg(userScore) FROM [quiz] WHERE "& strSort &"=a."& strSort &" AND regMail=a.regMail) AS avgScore, " &_
    "Count(id) AS quizCount, Sum(iif(passState, 1, 0)) AS passCount, Sum(iif(Not passState, 1, 0)) AS failCount " &_
    "FROM [quiz] a"  
  If Session("Sys") Then
    'do nothing
  ElseIf Session("Admin") <> "" Then
    strSql = strSql & " WHERE regMail='"& Session("Admin") &"'"
  Else
    strSql = strSql & " WHERE regMail=''"
  End If
  strSql = strSql & " GROUP BY "& strSort &", regMail"
%>
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
      var w = window.open("pie.asp?p="+ p +"&f="+ f + "&t=" + t + "&u=" + u + "&a=" + admin, "ͼ����ʾ", "height=445, width=625, toolbar=no, menubar=no, scrollbars=no, resizable=no,location=no, status=no"); 
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
    <td colspan="10" align="center" height="20" width="983"><font size="3" color="#006699"><b>������Ϣͳ��</b></font></td>
  </tr>
  <tr>
    <td background="images/tbg.gif" width="4%" height="20">��� </td>
    <td background="images/tbg.gif" width="34%" height="20"><%If strType = "quiz" Then%>����<%Else%>�û�<%End If%> </td>
    <%
      If Session("Sys") Then
    %>
    <td background="images/tbg.gif" width="17%" height="20">����Ա</td>
    <%
      End If
    %>
    <td background="images/tbg.gif" width="6%" height="20">��߷�</td>
    <td background="images/tbg.gif" width="6%" height="20">��ͷ�</td>
    <td background="images/tbg.gif" width="6%" height="20">ƽ����</td>
    <td background="images/tbg.gif" width="7%" height="20">������</td>
    <td background="images/tbg.gif" width="7%" height="20">������ </td>
    <td background="images/tbg.gif" width="7%" height="20">�������� </td>
    <td background="images/tbg.gif" width="6%" height="20">ͼ�� </td>
  </tr>
  <form name="frmQuiz" method="POST" action="stat.asp?del=true">
  <%
    Set rs = Server.CreateObject("ADODB.Recordset")
    rs.Open strSql, conn, 3
    If rs.RecordCount <> 0 Then
      Dim curPage
      rs.PageSize = g_pageSize
      If strPage <> "" Then
        curPage = CLng(strPage)
      Else
        curPage = 0
      End If
      If curPage < 1 Then curPage = 1
      If curPage > rs.PageCount Then curPage = rs.PageCount
      rs.AbsolutePage = curPage
      
      For i = 0 To rs.PageSize - 1
        If rs.PageSize * (curPage - 1) + i >= rs.RecordCount Then Exit For
      
        Dim recNo
        recNo = rs.PageSize * (curPage - 1) + i + 1
        Dim st
        st = rs(""& strSort &"")
  %>
  <tr <%If i Mod 2 <> 0 Then%> bgcolor="#E0E0E0"<%End If%>>
    <td height="20"><%=recNo%>��</td>
    <td height="20"><a href="ques.asp?sort=<%=Server.URLEncode(st)%>&admin=<%=rs("regMail")%>&type=<%=strType%>" title="����鿴��ϸ��Ϣ" target="_blank"><%=st%></a></td>
    <%
        If Session("Sys") Then
    %>
    <td height="20"><%=rs("regMail")%>��</td>
    <%
        End If
    %>
    <td height="20"><a href="ques.asp?sort=<%=Server.URLEncode(st)%>&admin=<%=rs("regMail")%>&type=<%=strType%>&score=<%=rs("maxScore")%>" title="����鿴��߷ּ�¼" target="_blank"><%=rs("maxScore")%></a>��</td>
    <td height="20"><a href="ques.asp?sort=<%=Server.URLEncode(st)%>&admin=<%=rs("regMail")%>&type=<%=strType%>&score=<%=rs("minScore")%>" title="����鿴��ͷּ�¼" target="_blank"><%=rs("minScore")%></a>��</td>
    <td height="20"><%=Round(rs("avgScore"), 2)%>��</td>
    <td height="20"><%=rs("quizCount")%>��</td>
    <td height="20"><a href="ques.asp?sort=<%=Server.URLEncode(st)%>&admin=<%=rs("regMail")%>&type=<%=strType%>&pass=true" title="����鿴�����¼" target="_blank"><font color="#008000"><%=rs("passCount")%></font></a></td>
    <td height="20"><a href="ques.asp?sort=<%=Server.URLEncode(st)%>&admin=<%=rs("regMail")%>&type=<%=strType%>&fail=true" title="����鿴�������¼" target="_blank"><font color="#FF0000"><%=rs("failCount")%></font></a></td>
    <td height="20"><a href="#" onClick="javascript: showPie(<%=rs("passCount")&", "&rs("failCount")&", '"&strType&"'"&", '"&Server.URLEncode(st)&"', '"&rs("regMail")&"'"%>); return false"><img border="0" src="images/chart.gif" align="absbottom" width="15" height="15"></a> </td>
  </tr>
  <%
        rs.MoveNext
      Next
  %>
  </form>
  <tr>
    <td colspan="3" align="left" height="18" width="589">
      ͳ�Ʒ�����<select size="1" name="cbType" onChange="javascript: window.location.href='stat.asp?type=' + this.options[this.selectedIndex].value">
      <option value="quiz" <%If strType = "quiz" Then%>selected<%End If%>>������ͳ��</option>
      <option value="user" <%If strType = "user" Then%>selected<%End If%>>���û�ͳ��</option>
      </select>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      <font color="#008000">��Ϣ����[<%=rs.RecordCount%>]</font>&nbsp;&nbsp;
      <font color="#008000"><img border="0" src="images/page.gif" align="absbottom">ҳ�Σ�[<%="<font color=""#FF0000"">"& curPage &"</font>/"& rs.PageCount%>]
    </td>
    <td colspan="7" align="right" height="18" width="393">
      <%If curPage <> 1 Then%>
      <a href="stat.asp?page=1&type=<%=strType%>">[�� ҳ]</a>&nbsp;&nbsp;
      <a href="stat.asp?page=<%=curPage - 1%>&type=<%=strType%>">[��һҳ]</a>&nbsp;&nbsp;
      <%
        End If
        If curPage <= rs.PageCount - 1 Then
      %>
      <a href="stat.asp?page=<%=curPage + 1%>&type=<%=strType%>">[��һҳ]</a>&nbsp;&nbsp;
      <a href="stat.asp?page=<%=rs.PageCount%>&type=<%=strType%>">[ĩ ҳ]</a>
      <%
        End If
      %>
    </td>
  </tr>
  <%
    End If
    Set rs = Nothing
  %>
</table>
</center>

</body>

</html>