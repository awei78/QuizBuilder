
<%
  Option Explicit
  If Not Session("Sys") Then Response.Redirect "index.html"  
%>
<!-- #include file="fso.asp" -->

<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=gb2312">
<link rel="stylesheet" type="text/css" href="style.css">
<title>���ݿ����</title>
</head>

<%
  Dim strAct, bFlag, rFlag, cFlag
  strAct = Request.QueryString("act")
  
  If strAct = "backup" Then
    If fso.FileExists(Server.MapPath(Request.Form("bdbpath"))) Then
      fso.CopyFile Server.MapPath(Request.Form("bdbpath")), Server.MapPath(Request.Form("bdbbkpath"))
      bFlag = True
    Else
      bFlag = False
    End If
  End If
  
  If strAct = "restore" Then
    If fso.FileExists(Server.MapPath(Request.Form("rdbbkpath"))) Then
      fso.CopyFile Server.MapPath(Request.Form("rdbbkpath")), Server.MapPath(Request.Form("rdbpath"))
      rFlag = True
    Else
      rFlag = False
    End If
  End If
  
  If strAct = "compress" Then
    Dim dbPath
    dbPath = Server.MapPath(Request.Form("dbpath"))
    If dbPath <> "" And fso.FileExists(dbPath) Then
      Dim fs, oldSize, curSize
      Set fs = fso.GetFile(dbPath)
      oldSize = fs.Size
      Set fs = Nothing
      Dim strDBPath
      strDBPath = Left(dbpath, InStrRev(dbPath, "\"))
      
      Dim engine
      Set engine = CreateObject("jro.jetengine")
      engine.CompactDatabase "provider=microsoft.jet.oledb.4.0;data source="& dbPath, _
                             "provider=microsoft.jet.oledb.4.0;data source="& strDBPath &"temp.mdb"
      fso.CopyFile strDBPath &"temp.mdb", dbPath
      fso.DeleteFile strDBPath &"temp.mdb"
      Set fs = fso.GetFile(dbPath)
      curSize = fs.Size
      Set fs = Nothing
      Set engine = Nothing
      cFlag = True
    Else
      cFlag = False
    End If
  End If
%>

<body>

<center>
<table border="1" width="100%" cellpadding="0" cellspacing="0" bordercolor="#7F9DB9" style="border-collapse: collapse">
  <tr>
    <td colspan="6" align="center" height="20"><b><font size="3" color="#006699">
    ���ݿ����</font></b></td>
  </tr>
  <tr>
    <td width="100%" colspan="3" background="images/tbg.gif" height="18"><font color="#000080" face="����" size="2">���ݿⱸ��</font></td>
  </tr>
  <tr>
    <td width="20%" height="1"></td>
    <form method="POST" action="?act=backup">
    <td width="60%" height="1">
      <fieldset bordercolor="#FF00FF">
        <legend><font size="2" color="#000080">���ݿⱸ��</font></legend>
        <div style="margin-left: 8">
          ���ݿ�·����<input type="text" name="bdbpath" size="30" value="data.asa"><br>
          Ҫ����·����<input type="text" name="bdbbkpath" size="30" value="data.bak"><br>
          <br>
          <input type="submit" value="�� ��" name="backup">&nbsp;                                           
          <input type="reset" value="�� ��" name="reset">
          <%
            If strAct = "backup" Then
              If bFlag Then
                Response.Write "<font color=""#008000"">���ݳɹ���</font>"
              Else
                Response.Write "<font color=""#800000"">Դ�ļ������ڣ�����ʧ�ܣ�</font>"
              End If
            End If
          %>       
        </div>
      </fieldset>
    </td>
    </form> 
    <td width="20%" height="1"></td>
  </tr>
  <tr>
    <td width="100%" colspan="3" background="images/tbg.gif" height="18"><font color="#000080" face="����" size="2">���ݿ�ָ�</font></td>
  </tr>
  <tr>
    <td width="20%" height="1"></td>
    <form method="POST" action="?act=restore">
    <td width="60%" height="1">
      <fieldset bordercolor="#FF00FF">
        <legend><font size="2" color="#000080">���ݿ�ָ�</font></legend>
        <div style="margin-left: 8">
          ���ݵ�·����<input type="text" name="rdbbkpath" size="30" value="data.bak"><br>
          ���ݿ�·����<input type="text" name="rdbpath" size="30" value="data.asa"><br>
          <br>
          <input type="submit" value="�� ��" name="recover">&nbsp;                                           
          <input type="reset" value="�� ��" name="btnReset">
          <%
            If strAct = "restore" Then
              If rFlag Then
                Response.Write "<font color=""#008000"">�ָ��ɹ���</font>"
              Else
                Response.Write "<font color=""#800000"">Դ�ļ������ڣ��ָ�ʧ�ܣ�</font>"
              End If
            End If
          %>                                       
        </div>
      </fieldset>
    </td>
    </form> 
    <td width="20%" height="1"></td>
  </tr>
  <tr>
    <td width="100%" colspan="3" background="images/tbg.gif" height="18"><font color="#000080" face="����" size="2">���ݿ�ѹ��</font></td>
  </tr>
  <tr>
    <td width="20%" height="1"></td>
    <form method="POST" action="?act=compress">
    <td width="60%" height="1">
      <fieldset bordercolor="#FF00FF">
        <legend><font size="2" color="#000080">���ݿ�ѹ��</font></legend>
        <div style="margin-left: 8">
          ���ݿ�·����<input type="text" name="dbpath" size="30" value="data.asa"><br>
          <br>
          <input type="submit" value="ѹ ��" name="compress">&nbsp;                                     
          <input type="reset" value="�� ��" name="btnReset">
          <%
            If strAct = "compress" Then
              If cFlag Then
                Response.Write "<font color=""#008000"">ѹ���ɹ���&nbsp;&nbsp;ԭ����С��"& oldSize / 1024 &"K&nbsp;���ڴ�С��"& curSize / 1024 &"K</font>"
              Else
                Response.Write "<font color=""#800000"">Դ�ļ������ڣ�ѹ��ʧ�ܣ�</font>"
              End If
            End If
          %>
        </div>
      </fieldset>
    </td>
    </form> 
    <td width="20%" height="1"></td>
  </tr>
</table>
</center>

</body>

</html>