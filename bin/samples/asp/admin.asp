<!-- #include file="conn.asp" -->

<%
  If Session("Admin") = "" Then Response.Redirect "index.html"  

  Dim i, strInfo, strUrl, strPage, strSrh
  '�ݵ�¼����Ա���ò�ѯ
  If Session("Sys") = True Then
    strSrh = "True"
  ElseIf Session("Admin") <> "" Then
    strSrh = "userId='"& Session("Admin") &"'"
  Else
    strSrh = "False"
  End If
  
  strPage = Request.QueryString("page")
  If Not IsNumeric(strPage) Then strPage = "0"
  
  strInfo = Trim(Request("sinfo"))
  If strInfo = "" Then
    strUrl = ""
  Else
    strUrl = "&sinfo=" & Server.UrlEncode(strInfo)
  End If
  
  Dim strId, strUid, strPwd, inUse
  'ȡ�༭����
  strId = Request.QueryString("id") & ""
  If IsNumeric(strId) Then
    Set rs = conn.Execute("SELECT * FROM [admin] WHERE "& strSrh &" AND id=" & strId)
    If Not rs.EOF Then
      strUid = rs("userId")
      strPwd = rs("userPwd")
    End If
    Set rs = Nothing
  End If
    
  '�༭
  If Request.QueryString("act") = "edit" Then
    strPwd = Request.Form("userPwd")
    strId = Request.Form("id")
    conn.Execute("UPDATE [admin] SET userPwd='"&strPwd&"' WHERE id="&strId)
    
    Response.Redirect "admin.asp?page=" & strPage & strUrl
  End If

  'ɾ��.
  Dim delStr
  delStr = Trim(Request.QueryString("del"))
  'ɾ��������¼
  If IsNumeric(delStr) Then
    Set rs = conn.Execute("SELECT Sys FROM [admin] WHERE id="& delStr )
    If rs("Sys") Then
      Response.Write("<script language='javascript'>alert('������ɾ��ϵͳ����Ա��'); window.location.href='admin.asp'</script>")
    Else  
      conn.Execute ("DELETE FROM [admin] WHERE id="& delStr)
      Response.Redirect "admin.asp?page="& strPage & strUrl
    End If
  End If
%>

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
    <%If Session("Sys") Then%>
    <td background="images/tbg.gif" width="10%" height="20">ɾ��<img border="0" src="images/del.gif"></td>
    <%End If%>
    <td background="images/tbg.gif" width="10%" height="20">�༭<img border="0" src="images/write.gif"></td>
    <td background="images/tbg.gif" width="20%" height="20">��������</td>
  </tr>
  <%
    Set rs = Server.CreateObject("ADODB.Recordset")
    If strInfo = "" Then
      rs.Open "SELECT * FROM [admin] WHERE "& strSrh &" ORDER BY id DESC", conn, 3
    Else
      rs.Open "SELECT * FROM [admin] WHERE "& strSrh &" AND userId LIKE '%"& strInfo &"%' ORDER BY id DESC", conn, 3
    End If
    If rs.RecordCount <> 0 Then
      Dim curPage
      rs.PageSize = 18
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
        Dim strUser
        strUser = Replace(rs("userId"), strInfo, "<font color=""#FF0000"">"&strInfo&"</font>")
        
        '���¼����
        Dim rsc, recCount, userCount
        If LCase(rs("userId")) <> "admin" Then
          Set rsc = Conn.Execute("SELECT Count(id) AS recCount FROM [quiz] WHERE regMail='"& rs("userId") &"'")
        Else
          Set rsc = Conn.Execute("SELECT Count(id) AS recCount FROM [quiz]")
        End If
        If Not rsc.Eof then recCount= rsc("recCount")
        
        '����������
        If LCase(rs("userId")) <> "admin" Then
          Set rsc = Conn.Execute("SELECT Count(id) AS recCount FROM [users] WHERE admin='"& rs("userId") &"'")
        Else
          Set rsc = Conn.Execute("SELECT Count(id) AS recCount FROM [users]")
        End If
        If Not rsc.Eof then userCount= rsc("recCount")
        
        Set rsc = Nothing        
  %>
  <tr <%If i Mod 2 <> 0 Then%> bgcolor="#E0E0E0"<%End If%>>
    <td height="20"><%=recNo%>��</td>
    <td height="20"><a href="ques.asp?admin=<%=Server.URLEncode(rs("userId"))%>" title="�鿴�˹���Ա�������� [<%=recCount%>��]" target="_blank"><%=strUser%></a>��</td>
    <td height="20"><%=rs("userPwd")%>��</td>
    <td height="20"><a href="users.asp?sinfo=<%=rs("userId")%>"><%=userCount%></a>��</td>
    <%
        If Session("Sys") Then
    %>
    <td height="20"><a href="admin.asp?page=<%=curPage%>&del=<%=rs("id")%><%=strUrl%>" title="ɾ����ǰ��¼" onClick="javascript: <%If rs("Sys") Then%>alert('������ɾ��ϵͳ����Ա��');return false<%Else%>return confirm('��ȷ��ɾ�����ʺ�ô��')<%End If%>">ɾ��</a> </td>
    <%
        End If
    %>
    <td height="20"><a href="admin.asp?page=<%=curPage%>&id=<%=rs("id")%><%=strUrl%>" title="�༭��ǰ��¼">�༭</a></td>
    <td height="20"><%=rs("addDate")%>��</td>
  </tr>
  <%
        rs.MoveNext
      Next
      
      If Session("Sys") Then
  %>
  <tr>
    <td colspan="4" align="left" height="18" valign="bottom">
      <font color="#008000">��Ϣ����[<%=rs.RecordCount%>]</font>&nbsp;&nbsp;
      <font color="#008000">
      <img border="0" src="images/page.gif" align="absbottom">ҳ�Σ�[<%=curPage &"/"& rs.PageCount%>]</font>
    </td>
    <td colspan="3" align="right" height="18" valign="bottom">
      <%if curPage <> 1 then%>
      <a href="admin.asp?page=1<%=strUrl%>">[�� ҳ]</a>&nbsp;&nbsp;
      <a href="admin.asp?page=<%=curPage - 1%><%=strUrl%>">[��һҳ]</a>&nbsp;&nbsp;
      <%
        End If
        If curPage <= rs.PageCount - 1 Then
      %>
      <a href="admin.asp?page=<%=curPage + 1%><%=strUrl%>">[��һҳ]</a>&nbsp;&nbsp;
      <a href="admin.asp?page=<%=rs.PageCount%><%=strUrl%>">[ĩ ҳ]</a>
      <%
        End If
      %>
    </td>
  </tr>
  <%
      End If
    End If
    Set rs = Nothing
    
    If Session("Sys") Then
  %>
  <form name="frmSearch" method="GET" action="admin.asp">
  <tr>
    <td colspan="7" align="left">
      <font color="#006699"><b>��������Ҫ�������ʺţ�</b></font>&nbsp;
      <input type="text" name="sinfo" size="32" value="<%=strInfo%>" ID=Text1>&nbsp;
      <input type="submit" value="����" ID=Submit1></td>
  </tr>
  <%
    End If
  %>
  </form>
</table>

<%
  If strId <> "" Then
%>
<br><br>
<table border="1" width="90%" cellspacing="0" cellpadding="0" style="border-collapse: collapse" bordercolor="#7F9DB9">
  <form name="frmAdd" method="POST" action="?page=<%=curPage%><%=strUrl%>&act=edit" onSubmit="javascript: return checkData()" onReset="javascript: document.all('info').innerHTML = ''; this.userId.focus()">
  <tr>
    <td width="25%" align="right">�ʺţ�&nbsp; </td>
    <td width="75%">
    <input type="input" name="userId" value="<%=strUid%>" disabled style="width: 180; height: 20" size="20">&nbsp; <label id="info"></label></td>
  </tr>
  <tr>
    <td width="25%" align="right">���룺&nbsp; </td>
    <td width="75%">
    <input type="input" name="userPwd" value="<%=strPwd%>" style="width: 180; height: 20" size="20"></td>
  </tr>
  <tr>
    <td width="25%"></td>
    <td width="75%">
      <input type="submit" value="����" name="btnTurn">&nbsp;&nbsp;&nbsp;
      <input type="reset" value="����" name="btnReset">&nbsp;&nbsp;&nbsp;
      <%If strId <> "" Then%>
        <input type="hidden" name="id" value="<%=strId%>">
        <input type="button" value="ȡ��" name="btnCancel" onClick="javascript: window.location.href='admin.asp'">
      <%End If%>
    </td>
  </tr>
  </form>
</table>
<%
  End If
%>

</body>

</html>