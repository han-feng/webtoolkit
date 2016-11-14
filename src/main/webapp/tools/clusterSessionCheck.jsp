<%@page import="java.util.*,java.net.*,java.io.*,java.lang.reflect.*"
	language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%
	//
	final String sessionkey1 = "testRandom";
	final String sessionkey2 = "testObject";
	final String sessionkey3 = "testObject2";

	response.setHeader("Pragma", "no-cache");
	response.setHeader("Cache-Control", "no-cache");
	response.setDateHeader("Expires", 0);

	String numStr = request.getParameter("random");
	String timeStr = request.getParameter("time");
	String serverIp = request.getLocalAddr();
	int serverPort = request.getLocalPort();
	String contextPath = request.getContextPath();
	String sessionId = session.getId();
	String server = serverIp + ":" + serverPort;
	String cookie = request.getHeader("Cookie");
	if (cookie == null)
		cookie = "";

	long newTime = System.currentTimeMillis();

	Object oldNumObj = session.getAttribute(sessionkey1);
	int newNum = new Random().nextInt();
	session.setAttribute(sessionkey1, new Integer(newNum));

	TestObject oldTestObj = null, oldTestObj2 = null;

	try {
		oldTestObj = (TestObject) session.getAttribute(sessionkey2);
	} catch (Exception e) {
	}
	session.setAttribute(sessionkey2, new TestObject(newNum));

	try {
		oldTestObj2 = (TestObject) session.getAttribute(sessionkey3);
	} catch (Exception e) {
	}
	session.setAttribute(sessionkey3, new TestObject2(newNum));

	long time = session.getCreationTime();
	if (timeStr != null) {
		time = Long.parseLong(timeStr);
	}

	if (numStr != null) {
		boolean validate1 = false;
		int validate2 = 0, validate3 = 0;
		int reqNum = Integer.parseInt(numStr);
		if (oldNumObj != null) {
			if (((Integer) oldNumObj).intValue() == reqNum) {
				validate1 = true;
			}
		}
		if (oldTestObj != null) {
			validate2 = oldTestObj.validate(reqNum, time);
		}
		if (oldTestObj2 != null) {
			validate3 = oldTestObj2.validate(reqNum, time);
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
		out.print(",\"time\":");
		out.print(newTime);
		out.print(",\"validate1\":");
		out.print(validate1);
		out.print(",\"validate2\":");
		out.print(validate2);
		out.print(",\"validate3\":");
		out.print(validate3);
		out.print("}");
		return;
	}
%>
<%!//
	/**
	 * 测试用非序列化对象
	 */
	static public class TestObject {
		private TestObject1 obj;
		private Map map = new HashMap();
		private List list = new ArrayList();
		private Date date = new Date();
		public TestObject(int num) {
			this.obj = new TestObject1(num);
			for (int i = 0; i < 10; i++) {
				map.put("key" + i, "test" + i + ":" + num);
				list.add("test" + i + ":" + num);
			}
		}
		public int hashCode() {
			return obj.num;
		}
		public String toString() {
			return this.getClass().getName() + "{ hashCode: " + hashCode() + ", date: " + date + " }";
		}
		public int validate(int num, long time) {
			if (obj == null)
				return 1;
			if (obj.num != num)
				return 2;
			if (date == null)
				return 3;
			if (date.getTime() < time)
				return 4;
			if (date.getTime() > System.currentTimeMillis())
				return 5;
			if (map == null)
				return 6;
			if (map.size() != 10)
				return 7;
			if (list == null)
				return 8;
			if (list.size() != 10)
				return 9;
			return -1;
		}
		class TestObject1 {
			int num;
			TestObject1(int num) {
				this.num = num;
			}
		}
	}
	/**
	 * 测试用序列化对象
	 */
	static public class TestObject2 extends TestObject implements Serializable {
		public TestObject2(int num) {
			super(num);
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
	var stime = <%=newTime%>;
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
				<th>Request Cookie *</th>
				<th>系统时钟差（分钟） *</th>
			</tr>
		</table>
	</div>
	<div>
		<label>检测总次数：</label><span id="count"></span> <label
			style="margin-left: 30px">最后检测时间：</label><span id="lasttime"></span>
	</div>
	<div style="font-size: 0.8em;">* 注：服务节点、会话内容验证、Session Id、Request
		Cookie 内容无变化且系统时钟差不超过5分钟时不再重复显示。系统时钟差，是指客户端系统时间与服务端系统时间之差</div>
	<script src="jquery.min.js"></script>
	<script type="text/javascript">
		function log(time, server, sessionStr, validateStr, requestCookieStr,
				timeDiff) {
			var newRow = "<tr><td>" + count + "</td><td>" + time + "</td><td>"
					+ server + "</td><td>" + validateStr + "</td><td>"
					+ sessionStr + "</td><td>" + document.cookie + "</td><td>"
					+ requestCookieStr + "</td><td>" + timeDiff + "</td></tr>";
			$("#logTable tr:last").after(newRow);
			$('html, body').animate({
				scrollTop : $(document).height()
			}, 'slow');
		}
		function getTimeStr(dTime) {
			return dTime.getHours() + ":" + dTime.getMinutes() + ":"
					+ dTime.getSeconds() + "," + dTime.getMilliseconds();
		}
		function getServerInfo() {
			var startTime = new Date().getTime();
			$.get("?random=" + random + "&time=" + stime, function(data) {
				var now = new Date();
				var time = getTimeStr(now);
				count++;
				$("#count").html(count);
				$("#lasttime").html(time);
				data = $.parseJSON(data);
				var changed = false;
				var newServer = data.serverIp + ":" + data.serverPort;
				var newSessionId = data.sessionId;
				random = data.random;
				stime = data.time;
				var newRequestCookie = data.requestCookie;
				var timeDiff = (now.getTime() - startTime) / 2 + startTime
						- stime;
				// console.log("timeDiff: " + timeDiff + " ms");
				timeDiff = Math.round(timeDiff / 60000);
				if (timeDiff > 5 || timeDiff < -5) {
					changed = true;
					timeDiff = "<span style=\"color: red\">" + timeDiff
							+ "</span>";
				}
				if (requestCookie != newRequestCookie) {
					changed = true;
					requestCookie = newRequestCookie;
					newRequestCookie = "<span style=\"color: red\">"
							+ requestCookie + "</span>";
				}
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
					validStr += "<li style=\"color: green\">简单对象验证成功</li>";
				} else if (data.validate1 == false) {
					validStr += "<li style=\"color: red\">简单对象验证失败</li>";
					//changed = true;
				}
				if (data.validate3 < 0) {
					validStr += "<li style=\"color: green\">序列化对象验证成功</li>";
				} else {
					validStr += "<li style=\"color: red\">序列化对象验证失败 ["
							+ data.validate3 + "]</li>";
					//changed = true;
				}
				if (data.validate2 < 0) {
					validStr += "<li style=\"color: green\">非序列化对象验证成功</li>";
				} else {
					validStr += "<li style=\"color: red\">非序列化对象验证失败 ["
							+ data.validate2 + "]</li>";
					//changed = true;
				}
				validStr += "</ul>";
				if (validateMsg != validStr) {
					changed = true;
					validateMsg = validStr
				}
				if (changed)
					log(time, newServer, newSessionId, validStr,
							newRequestCookie, timeDiff);
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
		$(document).ready(
				function() {
					log(getTimeStr(new Date()), server, sessionId, validateMsg,
							requestCookie, "");
					$("#loopbox").click(checkLoopbox);
					checkLoopbox();
				});
	</script>
</body>
</html>
