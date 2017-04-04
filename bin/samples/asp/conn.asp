<%
 '当您在浏览器中看到这句话时，说明您的电脑不支持Asp运行环境，Asp例子将不能运行
      
  Option Explicit
  Response.CacheControl = "no-cache"
  Dim g_pageSize
  g_pageSize = 24
  
  Dim conn, rs
  If Not IsObject(conn) Then
    Set conn = Server.CreateObject("ADODB.Connection")
    conn.Open "Provider=Microsoft.Jet.OLEDB.4.0; Data Source="&Server.MapPath("data.asa")
  End If
	
	Sub CloseDatabase()
		rs.Close
		Set rs = Nothing
		conn.Close
		Set conn = Nothing
	End Sub
	
	Function iif(expression, true_value, false_value)   
    If expression Then 
      iif = true_value  
    Else
      iif = false_value  
    End If 
  End Function
	
	'字符串操作
	Function EncodeHtml(Str)
	  EncodeHtml = Replace(Str, "&", "&amp;")
		EncodeHtml = Replace(EncodeHtml, "<", "&lt;")
		EncodeHtml = Replace(EncodeHtml, ">", "&gt;")
		EncodeHtml = Replace(EncodeHtml, """", "&quot;")
		EncodeHtml = Replace(EncodeHtml, "'", "&apos;")
		EncodeHtml = Replace(EncodeHtml, vbCrLf, "<br>")
		EncodeHtml = Replace(EncodeHtml, " ", "&nbsp;")
	End Function
	
	Function DecodeHtml(Str)
	  DecodeHtml = Replace(Str, "&amp;", "&")
		DecodeHtml = Replace(DecodeHtml, "&lt;", "<")
		DecodeHtml = Replace(DecodeHtml, "&gt;", ">")
		DecodeHtml = Replace(DecodeHtml, "&quot;", """")
		DecodeHtml = Replace(DecodeHtml, "&apos;", "'")
		DecodeHtml = Replace(DecodeHtml, "<br>", vbCrLf)
		DecodeHtml = Replace(DecodeHtml, "&nbsp;", " ")	
	End Function
%>