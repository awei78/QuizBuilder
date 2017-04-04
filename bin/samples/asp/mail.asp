<%
  If Request.Form("topic") = "" Then
    Response.Write "无效的邮件数据！此页面为试题大师所生成的试题所调用，不能直接用浏览器打开"
    Response.End
  End If
  
  Dim strMail, strFrom, strUser, strSubject, strBody
  strMail    = Request.Form("mail")
  strSubject = Request.Form("topic")
  strBody    = Request.Form("body")
  strFrom    = Request.Form("from")
  If strFrom = "" Then strFrom = "quiz@awindsoft.net"
  strUser    = Request.Form("user")
  if strUser = "" Then strUser = strFrom

  On Error Resume Next
  '定义邮件
  Dim JMail    
  Set JMail = Server.CreateObject("JMail.Message")  
  JMail.Charset = "gb2312" 
  JMail.ContentType = "text/html"
  '测试发现，JMail.From，必须与发邮件的帐号相同。花我一天时间，汗……
  JMail.From = "quiz@awindsoft.net"
  JMail.FromName = strUser
  
  Dim i, arrMail
  arrMail = Split(strMail, ",")
  For i = LBound(arrMail) To UBound(arrMail)
    JMail.AddRecipient Trim(arrMail(i))
  Next
		
  JMail.Subject = strSubject 
  JMail.HTMLBody = strBody
  JMail.MailServerUserName = "quiz@awindsoft.net"
  JMail.MailServerPassword = "98765432"
  JMail.Priority = 3 
		
  '发信
  JMail.Send("smtp.awindsoft.net") 
  JMail.Close()
  Set JMail=Nothing  
	
  '返回信息 
  If Err.Number <> 0 Then 
    Response.Write "feedMsg=邮件发送失败！"
  Else 
    Response.Write "feedMsg=邮件已成功发送。"
  End If 
%>