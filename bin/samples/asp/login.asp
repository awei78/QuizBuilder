<!-- #include file="conn.asp" -->
<%
  If Request.Querystring("act") = "login" Then
    Dim strUser, strPwd
    strUser = Request.Form("userId")
    strPwd = Request.Form("userPwd")
    Set rs = conn.Execute("select * from [admin] where [userId]='" & strUser & "' and [userPwd]='" & strPwd & "'")
    If Not rs.Eof Then
      If CStr(Request.Form("vCode")) = CStr(Session("vCode")) Then      
		Session("Admin") = strUser
		Session("Sys") = rs("sys")
		Response.Redirect "index.asp"
	  Else
	    Response.Write("<script language='javascript'>alert('��֤������������������룡'); window.history.back()</script>")
	  End If
    Else
      Response.Write("<script language='javascript'>alert('�ʺŻ������д������������룡'); window.history.back()</script>")
    End If
  Else
    Session.Abandon()
    Response.Redirect("index.asp")
  End If
%>