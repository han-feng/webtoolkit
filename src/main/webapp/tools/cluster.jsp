<%@page import="java.util.*,java.net.*,java.io.*,java.lang.reflect.*"
	language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%
    //
			final String sessionkey1 = "testRandom";
			final String sessionkey2 = "testObject";

			response.setHeader("Pragma", "no-cache");
			response.setHeader("Cache-Control", "no-cache");
			response.setDateHeader("Expires", 0);

			String numStr = request.getParameter("random");
			String serverIp = request.getLocalAddr();
			int serverPort = request.getLocalPort();
			String contextPath = request.getContextPath();
			String sessionId = session.getId();
			String server = serverIp + ":" + serverPort;
			String cookie = request.getHeader("Cookie");

			Object oldNumObj = session.getAttribute(sessionkey1);
			int newNum = new Random().nextInt();
			session.setAttribute(sessionkey1, new Integer(newNum));

			Object oldTestObj = session.getAttribute(sessionkey2);
			session.setAttribute(sessionkey2, new TestObject(newNum));

			if (numStr != null) {
				boolean validate1 = false, validate2 = false;
				int reqNum = Integer.parseInt(numStr);
				if (oldNumObj != null) {
					if (((Integer) oldNumObj).intValue() == reqNum) {
						validate1 = true;
					}
				}
				if (oldTestObj != null && oldTestObj.hashCode() == reqNum) {
					validate2 = true;
				}

				if (!validate1) {
					System.out.println("cluster session validate1 error : "
							+ oldNumObj + " != " + reqNum);
				}

				if (!validate1) {
					System.out.println("cluster session validate2 error : "
							+ oldTestObj + ".hashCode() != " + reqNum);
				}

				out.print("{\"serverIp\":\"");
				out.print(serverIp);
				out.print("\",\"serverPort\":");
				out.print(serverPort);
				out.print(",\"contextPath\":\"");
				out.print(contextPath);
				out.print("\",\"sessionId\":\"");
				out.print(sessionId);
				out.print("\",\"requestCookie\":\"");
				out.print(cookie);
				out.print("\",\"random\":");
				out.print(newNum);
				out.print(",\"validate1\":");
				out.print(validate1);
				out.print(",\"validate2\":");
				out.print(validate2);
				out.print("}");
				return;
			}
%>
<%!/**
	 * 测试用非序列化对象
	 */
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

td ul {
	padding-left: 10px;
}

li {
	white-space: nowrap;
}
</style>
<script type="text/javascript">
	var server = "<%=server%>";
	var sessionId = "<%=sessionId%>";
	var requestCookie = "<%=cookie%>";
	var random = <%=newNum%>;
	var validateMsg = "";
	var ajaxTimeOut = 1000;
	var loop = true;
	var handle = null;
	var count = 1;
</script>
</head>
<body>
	<h2>集群会话验证工具</h2>
	<div>
		<input id="loopbox" type="checkbox" checked><label
			for="loopbox">循环检测（间隔 1 秒）</label>
	</div>
	<div>
		<table id="logTable">
			<tr>
				<th></th>
				<th>时间</th>
				<th>服务节点 *</th>
				<th>会话内容验证 *</th>
				<th>Session Id *</th>
				<th>Client Cookie</th>
				<th>Request Cookie</th>
			</tr>
		</table>
	</div>
	<div>
		<label>检测总次数：</label><span id="count"></span> <label
			style="margin-left: 30px">最后检测时间：</label><span id="lasttime"></span>
	</div>
	<div style="font-size: 0.8em;">* 注：服务节点、会话内容验证、Session Id
		内容无变化时不再重复显示。</div>
	<script src="jquery.min.js"></script>
	<script type="text/javascript">
		function log(time, server, sessionStr, validateStr) {
			var newRow = "<tr><td>" + count + "</td><td>" + time + "</td><td>"
					+ server + "</td><td>" + validateStr + "</td><td>"
					+ sessionStr + "</td><td>" + document.cookie + "</td><td>"
					+ requestCookie + "</td></tr>";
			$("#logTable tr:last").after(newRow);
			$('html, body').animate({
				scrollTop : $(document).height()
			}, 'slow');
		}
		function getTimeStr() {
			var now = new Date();
			return now.getHours() + ":" + now.getMinutes() + ":"
					+ now.getSeconds() + "," + now.getMilliseconds();
		}
		function getServerInfo() {
			$.get("?random=" + random, function(data) {
				var time = getTimeStr();
				count++;
				$("#count").html(count);
				$("#lasttime").html(time);
				data = $.parseJSON(data);
				var changed = false;
				var newServer = data.serverIp + ":" + data.serverPort;
				var newSessionId = data.sessionId;
				random = data.random;
				requestCookie = data.requestCookie;
				if (server != newServer) {
					changed = true;
					server = newServer;
					newServer = "<span style=\"color: red\">" + server
							+ "</span>";
				}
				if (sessionId != newSessionId) {
					changed = true;
					sessionId = newSessionId;
					newSessionId = "<span style=\"color: red\">" + sessionId
							+ "</span>";
				}
				var validStr = "<ul>";
				if (data.validate1 == true) {
					validStr += "<li style=\"color: green\">一般对象验证成功</li>";
				} else if (data.validate1 == false) {
					validStr += "<li style=\"color: red\">一般对象验证失败</li>";
					changed = true;
				}
				if (data.validate2 == true) {
					validStr += "<li style=\"color: green\">非序列化对象验证成功</li>";
				} else if (data.validate2 == false) {
					validStr += "<li style=\"color: red\">非序列化对象验证失败</li>";
					changed = true;
				}
				validStr += "</ul>";
				if (validateMsg != validStr) {
					changed = true;
					validateMsg = validStr
				}
				if (changed)
					log(time, newServer, newSessionId, validStr);
			});
		}
		function checkLoopbox() {
			if ($("#loopbox").is(":checked")) {
				if (!handle) {
					handle = window.setInterval(getServerInfo, ajaxTimeOut);
				}
			} else {
				if (handle) {
					window.clearInterval(handle);
					handle = null;
				}
			}
		}
		$(document).ready(function() {
			log(getTimeStr(), server, sessionId, validateMsg);
			$("#loopbox").click(checkLoopbox);
			checkLoopbox();
		});
	</script>
</body>
</html>
