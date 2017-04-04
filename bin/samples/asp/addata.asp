
<%
  Option Explicit
  If Not Session("Sys") Then Response.Redirect "index.html"  
%>
<!-- #include file="fso.asp" -->

<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=gb2312">
<link rel="stylesheet" type="text/css" href="style.css">
<title>数据库管理</title>
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
    数据库管理</font></b></td>
  </tr>
  <tr>
    <td width="100%" colspan="3" background="images/tbg.gif" height="18"><font color="#000080" face="宋体" size="2">数据库备份</font></td>
  </tr>
  <tr>
    <td width="20%" height="1"></td>
    <form method="POST" action="?act=backup">
    <td width="60%" height="1">
      <fieldset bordercolor="#FF00FF">
        <legend><font size="2" color="#000080">数据库备份</font></legend>
        <div style="margin-left: 8">
          数据库路径：<input type="text" name="bdbpath" size="30" value="data.asa"><br>
          要备份路径：<input type="text" name="bdbbkpath" size="30" value="data.bak"><br>
          <br>
          <input type="submit" value="备 份" name="backup">&nbsp;                                           
          <input type="reset" value="重 置" name="reset">
          <%
            If strAct = "backup" Then
              If bFlag Then
                Response.Write "<font color=""#008000"">备份成功！</font>"
              Else
                Response.Write "<font color=""#800000"">源文件不存在，备份失败！</font>"
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
    <td width="100%" colspan="3" background="images/tbg.gif" height="18"><font color="#000080" face="宋体" size="2">数据库恢复</font></td>
  </tr>
  <tr>
    <td width="20%" height="1"></td>
    <form method="POST" action="?act=restore">
    <td width="60%" height="1">
      <fieldset bordercolor="#FF00FF">
        <legend><font size="2" color="#000080">数据库恢复</font></legend>
        <div style="margin-left: 8">
          备份的路径：<input type="text" name="rdbbkpath" size="30" value="data.bak"><br>
          数据库路径：<input type="text" name="rdbpath" size="30" value="data.asa"><br>
          <br>
          <input type="submit" value="恢 复" name="recover">&nbsp;                                           
          <input type="reset" value="重 置" name="btnReset">
          <%
            If strAct = "restore" Then
              If rFlag Then
                Response.Write "<font color=""#008000"">恢复成功！</font>"
              Else
                Response.Write "<font color=""#800000"">源文件不存在，恢复失败！</font>"
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
    <td width="100%" colspan="3" background="images/tbg.gif" height="18"><font color="#000080" face="宋体" size="2">数据库压缩</font></td>
  </tr>
  <tr>
    <td width="20%" height="1"></td>
    <form method="POST" action="?act=compress">
    <td width="60%" height="1">
      <fieldset bordercolor="#FF00FF">
        <legend><font size="2" color="#000080">数据库压缩</font></legend>
        <div style="margin-left: 8">
          数据库路径：<input type="text" name="dbpath" size="30" value="data.asa"><br>
          <br>
          <input type="submit" value="压 缩" name="compress">&nbsp;                                     
          <input type="reset" value="重 置" name="btnReset">
          <%
            If strAct = "compress" Then
              If cFlag Then
                Response.Write "<font color=""#008000"">压缩成功！&nbsp;&nbsp;原来大小："& oldSize / 1024 &"K&nbsp;现在大小："& curSize / 1024 &"K</font>"
              Else
                Response.Write "<font color=""#800000"">源文件不存在，压缩失败！</font>"
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