<%@page import="java.util.*,javax.naming.*" language="java"
	contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	//
	response.setHeader("Pragma", "no-cache");
	response.setHeader("Cache-Control", "no-cache");
	response.setDateHeader("Expires", 0);

	String contextPath = request.getContextPath();

	InitialContext initCtx = new InitialContext();
	Hashtable env = initCtx.getEnvironment();
%>
<%!private static String toHTML(Object obj) {
		if (obj == null)
			return "";
		String value = obj.toString();
		if (value.length() > 128) {
			value = "<textarea readonly rows=\"10\" cols=\"80\">" + value + "</textarea>";
		} else {
			value = "<pre>" + value + "</pre>";
		}
		return value;
	}%>
<html>
<head>
<style type="text/css">
table {
	border-collapse: collapse;
	border: 1px solid black;
}

th {
	text-align: right;
}

th, td {
	padding: 5px;
}

th.caption {
	text-align: left;
	background-color: #ccc;
}
</style>
</head>
<body>
	<p>
		<a target="_blank" href="javaResource.jsp?resourceUri=jndi.properties">查找
			jndi.properties</a>
	</p>
	<table>
		<tr>
			<th class="caption" colspan="2">JNDI Environment</th>
		</tr>
		<%
			String key;
			for (Iterator<String> itr = env.keySet().iterator(); itr.hasNext();) {
				key = itr.next().toString();
		%>
		<tr>
			<th><%=key%>:</th>
			<td><%=toHTML(env.get(key))%></td>
		</tr>
		<%
			}
		%>
	</table>
</body>
</html>
