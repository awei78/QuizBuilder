<!-- #include file="conn.asp" -->

<%
  If Session("Admin") = "" Then Response.Redirect "index.html"  

  Dim i, delStr, strInfo, strPage, strUrl, strSrh
  '�ݵ�¼����Ա���ò�ѯ
  If Session("Sys") = True Then
    strSrh = "True"
  ElseIf Session("Admin") <> "" Then
    strSrh = "admin='"& Session("Admin") &"'"
  Else
    strSrh = "admin=''"
  End If
  
  strPage = Request.QueryString("page")
  If Not IsNumeric(strPage) Then strPage = "0"
  
  strInfo = Trim(Request("sinfo"))
  If strInfo = "" Then
    strUrl = ""
  Else
    strUrl = "&sinfo=" & Server.UrlEncode(strInfo)
  End If
  
  '�������������...
  '����
  If Request.QueryString("u") <> "" Then
    conn.Execute("UPDATE [users] SET inUse=True WHERE id="& Request.QueryString("u"))
  End If
  '����
  If Request.QueryString("r") <> "" Then
    conn.Execute("UPDATE [users] SET inUse=False WHERE id="& Request.QueryString("r"))
  End If
  
  Dim strId, strUid, strPwd, strMail, inUse
  'ȡ�༭����
  strId = Request.QueryString("id") & ""
  If IsNumeric(strId) Then
    Set rs = conn.Execute("SELECT * FROM [users] WHERE "& strSrh &" AND id="& strId)
    If Not rs.EOF Then
      strUid = rs("userId")
      strPwd = rs("userPwd")
      strMail = rs("userMail")
      inUse = rs("inUse")
    End If
    Set rs = Nothing
  End If
    
  Dim strAct
  strAct = Request.QueryString("act")
  '���
  If strAct = "add" Then
    strUid = Request.Form("userId")
    set rs = conn.Execute("SELECT id FROM [users] WHERE "& strSrh &" AND userId='"& strUid &"'")
    
    If Not rs.EOF Then
      Response.Write("<script language='javascript'>alert('��Ҫ��ӵ��ʺ� ["&strUid&"] �Ѵ��ڣ�'); window.location.href='users.asp'</script>")
    Else
      strPwd = Request.Form("userPwd")
      strMail = Request.Form("userMail")
      inUse = Request.Form("cbUse")
      If inUse = "" Then inUse = False
      conn.Execute("INSERT INTO [users](userId, userPwd, userMail, admin, inUse) VALUES('"& strUid &"', '"& strPwd &"', '"& strMail &"', '"& Session("Admin") &"', "& inUse &")")
      
      Response.Redirect "users.asp?page="& strPage & strUrl
    End If
    
    Set rs = Nothing
  End If
  
  '�༭
  If strAct = "edit" Then
    strUid = Replace(Request.Form("userId"), "'", "''")
    strId = Request.Form("id")
    set rs = conn.Execute("SELECT id FROM [users] WHERE "& strSrh &" AND userId='"& strUid &"' AND id <> "& strId)
    
    If Not rs.EOF Then
      Response.Write("<script language='javascript'>alert('��Ҫ���µ��ʺ� ["&strUid&"] �Ѵ��ڣ�'); window.history.back()</script>")
    Else
      strPwd = Request.Form("userPwd")
      strMail = Request.Form("userMail")
      inUse = Request.Form("cbUse")
      If inUse = "" Then inUse = False
      conn.Execute("UPDATE [users] SET userId='"& strUid &"', userPwd='"& strPwd &"', userMail='"& strMail &"', inUse="& inUse &" WHERE id="& strId)
      
      Response.Redirect "users.asp?page=" & strPage & strUrl
    End If
    
    Set rs = Nothing
  End If

  'ɾ��.
  delStr = Trim(Request.QueryString("del"))
  'ɾ��������¼
  If IsNumeric(delStr) Then
    conn.Execute ("DELETE FROM [users] WHERE id="& delStr)
    Response.Redirect "users.asp?page="& strPage & strUrl
  'ɾ����ѡ���¼      
  ElseIf delStr = "true" Then
    Dim delIds
    delIds = Request("id")
    conn.Execute("DELETE FROM [users] WHERE id IN ("& delIds &")")
    Response.Redirect "users.asp?page="& strPage & strUrl
  '��ռ�¼  
  ElseIf delStr = "all" Then
    If strInfo = "" Then
      conn.Execute ("DELETE FROM [users] WHERE "& strSrh)
    Else
      conn.Execute("DELETE FROM [users] WHERE "& strSrh &" AND userId LIKE '%"& strInfo &"%'")
    End If
    Response.Redirect "users.asp"
  End If
%>

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
  
  function selAll(state) {
    if (document.frmUser.id == undefined) {
      return;
    }
  
    document.all('sel').title = state ? 'ȡ��ѡ��' : 'ȫ��ѡ��';
    document.frmUser.id.checked = state;
    for (var i = 0; i <= document.frmUser.id.length - 1; i++) {
      document.frmUser.id[i].checked = state;
    }
  }
  
  function delAll() {
    var hasChecked = false;
    for (var i = 0; i <= document.frmUser.id.length - 1; i++) {
      if (document.frmUser.id[i].checked) {
        hasChecked = true;
        break;
      }
    }
    if (!hasChecked) {
      hasChecked = document.frmUser.id.checked;
    }
    
    if (!hasChecked) {
      alert('��ѡ��Ҫɾ�����˺���Ϣ��');
    }
    else if (confirm('��ȷ��Ҫɾ����ѡ�����Ϣ��')) {
      document.frmUser.submit();
    }
  }
  
  function clearAll() {
    if (confirm('��ȷ��Ҫ������м�¼��')) {
      window.location.href = 'users.asp?del=all&sinfo=<%=Server.URLEncode(strInfo)%>';
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
  <tr>
    <td background="images/tbg.gif" width="4%"><input type="checkbox" id="sel" value="sel" title="ȫ��ѡ��" onClick="javascript: selAll(this.checked)" style="cursor: hand"></td>
    <td background="images/tbg.gif" width="4%">���</td>
    <td background="images/tbg.gif" width="15%">�û��˺�</td>
    <td background="images/tbg.gif" width="10%">����</td>
    <td background="images/tbg.gif" width="14%">�ʼ�</td>
    <%
      If Session("Sys") Then
    %>
    <td background="images/tbg.gif" width="15%">����Ա</td>
    <%
      End If
    %>
    <td background="images/tbg.gif" width="8%">���ü��</td>
    <td background="images/tbg.gif" width="6%">ɾ��<img border="0" src="images/del.gif"></td>
    <td background="images/tbg.gif" width="6%">�༭<img border="0" src="images/write.gif"></td>
    <td background="images/tbg.gif" width="18%">��������</td>
  </tr>
  <%
    Set rs = Server.CreateObject("ADODB.Recordset")
    If strInfo = "" OR LCase(strInfo) = "admin" Then
      rs.Open "SELECT *, (SELECT Count(id) FROM [quiz] WHERE userId=users.userId) as [recCount] FROM [users] WHERE "& strSrh &" ORDER BY id DESC", conn, 3
    Else
      rs.Open "SELECT *, (SELECT Count(id) FROM [quiz] WHERE userId=users.userId) as [recCount] FROM [users] WHERE "& strSrh &" AND (userId LIKE '%"& strInfo &"%' OR admin LIKE '%"& strInfo &"%') ORDER BY id DESC", conn, 3
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
  %>
  <form name="frmUser" method="POST" action="?del=true<%=strUrl%>">
  <tr <%If i Mod 2 <> 0 Then%> bgcolor="#E0E0E0"<%End If%>>
    <td><input type="checkbox" name="id" value="<%=rs("id")%>"></td>
    <td><%=recNo%>��</td>
    <td><a href="ques.asp?user=<%=Server.URLEncode(rs("userId"))%>" title="�鿴���û��������� [<%=rs("recCount")%>��]" target="_blank"><%=strUser%></a>��</td>
    <td><%=rs("userPwd")%>��</td>
    <td><a href="mailto:<%=rs("userMail")%>" title="�����ʼ���<%=rs("userMail")%>"><%=rs("userMail")%></a>��</td>
    <%
        If Session("Sys") Then
    %>
    <td><%=Replace(rs("admin"), strInfo, "<font color=""#FF0000"">"&strInfo&"</font>")%> ��</td>
    <%
        End If
    %>
    <td>
    <%
        If rs("inUse") Then
          Response.Write "<a href=""users.asp?page="& curPage & strUrl &"&r="& rs("id") &""" title=""���õ�ǰ�˺ŵ������⹦��""><font color=""#FF0000"">����</font></a>"
        Else
          Response.Write "<a href=""users.asp?page="& curPage & strUrl &"&u="& rs("id") &""" title=""���õ�ǰ�˺ŵ������⹦��""><font color=""#008000"">����</font></a>"
        End If
    %> ��
    </td>
    <td><a href="users.asp?page=<%=curPage%>&del=<%=rs("id")%><%=strUrl%>" title="ɾ����ǰ��¼" onClick="javascript: return confirm('��ȷ��ɾ�����ʺ�ô��')">ɾ��</a> </td>
    <td><a href="users.asp?page=<%=curPage%>&id=<%=rs("id")%><%=strUrl%>" title="�༭��ǰ��¼">�༭</a></td>
    <td><%=rs("addDate")%>��</td>
  </tr>
  <%
        rs.MoveNext
      Next
  %>
  <tr>
    <td colspan="6" align="left" height="18" valign="bottom">
      <a href="#" onClick="javascript: delAll()">[�����ѡ��ļ�¼]</a>&nbsp;&nbsp;&nbsp;
      <img border="0" src="images/del.gif" align="absbottom"><a href="#" onClick="javascript: clearAll()">[������м�¼]</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      <font color="#008000">��Ϣ����[<%=rs.RecordCount%>]</font>&nbsp;&nbsp;
      <font color="#008000">
      <img border="0" src="images/page.gif" align="absbottom">ҳ�Σ�[<%=curPage &"/"& rs.PageCount%>]</font>
    </td>
    <td colspan="4" align="right" height="18" valign="bottom">
      <%if curPage <> 1 then%>
      <a href="users.asp?page=1<%=strUrl%>">[�� ҳ]</a>&nbsp;&nbsp;&nbsp;
      <a href="users.asp?page=<%=curPage - 1%><%=strUrl%>">[��һҳ]</a>&nbsp;&nbsp;&nbsp;
      <%
        End If
        If curPage <= rs.PageCount - 1 Then
      %>
      <a href="users.asp?page=<%=curPage + 1%><%=strUrl%>">[��һҳ]</a>&nbsp;&nbsp;&nbsp;
      <a href="users.asp?page=<%=rs.PageCount%><%=strUrl%>">[ĩ ҳ]</a>
      <%
        End If
      %>
    </td>
  </tr>
  </form>
  <form name="frmSearch" method="GET" action="users.asp">
  <tr>
    <td colspan="10" align="left">
      <font color="#006699"><b>��������Ҫ�������ʺţ�</b></font>&nbsp;
      <input type="text" name="sinfo" size="32" value="<%=strInfo%>">&nbsp;
      <input type="submit" value="����"></td>
  </tr>
  </form>
  <%
    End If
    Set rs = Nothing
  %>
</table>

<br><br>
<%
  Dim strCap
  If strId <> "" Then
    strAct = "edit"
    strCap = "����"
  Else
    strAct = "add"
    strCap = "���"
  End If
%>
<table border="1" width="90%" cellspacing="0" cellpadding="0" style="border-collapse: collapse" bordercolor="#7F9DB9">
  <form name="frmAdd" method="POST" action="?page=<%=curPage%><%=strUrl%>&act=<%=strAct%>" onSubmit="javascript: return checkData()" onReset="javascript: document.all('info').innerHTML = ''; this.userId.focus()">
  <tr>
    <td width="25%" align="right">��</td>
    <td width="75%"><b><font size="2" color="#006699"><%=strCap%>�ʺ�</font></b>��</td>
  </tr>
  <tr>
    <td width="25%" align="right">�ʺţ�&nbsp; </td>
    <td width="75%">
    <input type="input" name="userId" value="<%=strUid%>" style="width: 180; height: 20" size="20">&nbsp; <label id="info"></label></td>
  </tr>
  <tr>
    <td width="25%" align="right">���룺&nbsp; </td>
    <td width="75%">
    <input type="input" name="userPwd" value="<%=strPwd%>" style="width: 180; height: 20" size="20"></td>
  </tr>
  <tr>
    <td width="25%" align="right">�ʼ���&nbsp; </td>
    <td width="75%">
    <input type="input" name="userMail" value="<%=strMail%>" style="width: 180; height: 20" size="20"></td>
  </tr>
  <tr>
    <td width="25%" align="right">���ü�⣺&nbsp; </td>
    <td width="75%"><input type="checkbox" name="cbUse" value="True" <%If inUse Or strId = "" Then%>checked<%End If%>>&nbsp; 
    <font color="#0000FF">(�˴����ã���Ӧ�����ʦ��������֮<font color="#FF6600">[���Ᵽ��]</font>-><font color="#FF6600">[���뱣��]</font>-><font color="#FF6600">[��ҳ��֤]</font>֮ѡ��)</font></td>
  </tr>
  <tr>
    <td width="25%"></td>
    <td width="75%">
      <input type="submit" value="<%=strCap%>" name="btnTurn">&nbsp;&nbsp;&nbsp;
      <input type="reset" value="����" name="btnReset">&nbsp;&nbsp;&nbsp;
      <%If strId <> "" Then%>
        <input type="hidden" name="id" value="<%=strId%>">
        <input type="button" value="ȡ��" name="btnCancel" onClick="javascript: window.location.href='users.asp'">
      <%End If%>
    </td>
  </tr>
  </form>
</table>

</body>

</html>