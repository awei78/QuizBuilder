<%
  Dim fso  
  '创建FSO对象
  Sub CreateFSO
    On Error Resume Next
		Set fso = CreateObject("Scripting.FileSystemObject")
  End Sub
  
	'创建文件夹
	Sub CreateFolder(FolderPath)
	  If Not IsObject(fso) Then Exit Sub
	  On Error Resume Next
	  	
	  If Not fso.FolderExists(FilePath) then fso.CreateFolder(FolderPath)
	End Sub
	
	'据传入信息内容生成html文件
	Sub CreateHtmlFile(id, title, msg)
	  If Not IsObject(fso) Then Exit Sub
	  On Error Resume Next
	  
	  Dim htmlFile, f
	  htmlFile = Server.MapPath("data/" & id & ".html")
	  msg = Replace(msg, "''", "'")
	  Set f = fso.CreateTextFile(htmlFile, True)
	  f.WriteLine("<html>")
	  f.WriteLine("")
	  f.WriteLine("<head>")
	  f.WriteLine("<meta http-equiv=""Content-Type"" content=""text/html"">")
      f.WriteLine("<link rel=""stylesheet"" type=""text/css"" href=""../style.css"">")
	  f.WriteLine("<title>" & title & " - 测试结果</title>")
	  f.WriteLine("</head>")
	  f.WriteLine("")
	  f.WriteLine("<body background=""../images/bg.gif"">")
	  f.WriteLine("<table width=""97%"" align=""center"">")
	  f.WriteLine("  <tr>")
	  f.WriteLine("    <td align=""center""><font size=""4"">" & title & "</font></td>")
	  f.WriteLine("  </tr>")
	  f.WriteLine("  <tr>")
	  f.WriteLine("    <td>" & msg & "</td>")
	  f.WriteLine("  </tr>")
	  f.WriteLine("</table>")
	  f.WriteLine("<br><br>")
	  f.WriteLine("<center><a href=""#"" onClick=""javascript: self.opener = null; self.close()"">关闭窗口</a></center>")
	  f.WriteLine("</body>")
	  f.WriteLine("")
	  f.WriteLine("</html>")
	  
	  f.Close
	  Set f = Nothing	  
	End Sub
	
	'删除文件
	Sub DeleteFile(id)
	  If Not IsObject(fso) Then Exit Sub
	  On Error Resume Next
	  
	  Dim htmlFile
	  htmlFile = Server.MapPath("data/" & id & ".html")
	  If fso.FileExists(htmlFile) then fso.DeleteFile(htmlFile)
	End Sub	
	
	'执行部分
	Call CreateFSO
	Call CreateFolder(Server.MapPath("data"))
%>