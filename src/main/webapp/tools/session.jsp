<%@page
	import="java.text.SimpleDateFormat,java.util.*,java.net.*,java.io.*,java.lang.reflect.*"
	language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%
	//
	response.setHeader("Pragma", "no-cache");
	response.setHeader("Cache-Control", "no-cache");
	response.setDateHeader("Expires", 0);

	String name;
	Object value;
	StringBuilder msg = new StringBuilder();
	Map result = new HashMap();
	for (Enumeration names = session.getAttributeNames(); names.hasMoreElements();) {
		name = (String) names.nextElement();
		value = session.getAttribute(name);

		if (value instanceof Serializable) {
			msg.append("支持 Java 序列化： ");
			ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
			ObjectOutputStream objectOutputStream = new ObjectOutputStream(byteArrayOutputStream);
			long s = System.currentTimeMillis();
			objectOutputStream.writeObject(value);
			long e = System.currentTimeMillis() - s;
			msg.append(byteArrayOutputStream.size()).append(" byte , ").append(e).append(" ms");
		} else {
			msg.append("不支持 Java 序列化!");
		}

		result.put(name, msg.toString());
		msg.setLength(0);
	}
%>
<%!//
	private SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

	private String getTimeStr(long time) {
		return dateFormat.format(new Date(time));
	}

	static class TestObject {
		private TestObject1 obj;

		TestObject(int num) {
			this.obj = new TestObject1(num);
		}

		public int hashCode() {
			return obj.num;
		}

		public String toString() {
			return "TestObject{ hashCode: " + hashCode() + " }";
		}

		class TestObject1 {
			int num;

			TestObject1(int num) {
				this.num = num;
			}
		}
	}%>
<html>
<head>
<style type="text/css">
div {
	padding: 5px;
}

table {
	border-collapse: collapse;
	border-spacing: 0;
}

th, td {
	border: 1px solid #ccc;
	padding: 5px 10px;
}

td {
	font-size: 0.8em;
}
</style>
</head>
<body>
	<h2>会话信息查看工具</h2>
	<div>
		<table>
			<tr>
				<th>ID</th>
				<th>创建时间</th>
				<th>最后访问时间</th>
				<th>最大失效时间（秒）</th>
			</tr>
			<tr>
				<td><%=session.getId()%></td>
				<td><%=getTimeStr(session.getCreationTime())%></td>
				<td><%=getTimeStr(session.getLastAccessedTime())%></td>
				<td><%=session.getMaxInactiveInterval()%></td>
			</tr>
		</table>
	</div>
	<div>
		<table>
			<tr>
				<th>名称</th>
				<th>序列化</th>
			</tr>
			<%
				Map.Entry entry;
				for (Object obj : result.entrySet()) {
					entry = (Map.Entry) obj;
			%>
			<tr>
				<td><%=entry.getKey()%></td>
				<td><%=entry.getValue()%></td>
			</tr>
			<%
				}
			%>
		</table>
	</div>
</body>
</html>
