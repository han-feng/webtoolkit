<%@page import="java.util.*,java.net.*,java.io.*,java.lang.reflect.*"
	language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%
	response.setHeader("Pragma", "no-cache");
	response.setHeader("Cache-Control", "no-cache");
	response.setDateHeader("Expires", 0);

	String action = request.getParameter("action");
	List results = new ArrayList();
	if ("time".equals(action)) {
		// ajax 对时服务，返回系统时间 long
		out.print(System.currentTimeMillis());
		return;
	} else if ("check".equals(action)) {
		// ajax 集群检测服务，返回检测结果 json
		String servers = request.getParameter("servers"); // 集群节点地址列表
		String[] serversArray = servers.split("\n");
		String server;
		int len = serversArray.length;
		for (int i = 0; i < len; i++) {
			server = serversArray[i];
			if ("".equals(server))
				continue;
			results.add(new CheckResult(server));
		}
		len = results.size();
		for (int i = 0; i < len; i++) {
			((CheckResult) results.get(i)).check(request);
		}
%>
<table>
	<tr>
		<th>地址</th>
		<th>系统时钟差</th>
	</tr>
	<%
		for (int i = 0; i < len; i++) {
				CheckResult row = (CheckResult) results.get(i);
	%><tr>
		<td><%=row.add%></td>
		<td><%=row.timeDiff%></td>
	</tr>
	<%
		}
	%>
</table>
<%
	return;
	}
	// 工具初始界面
%>
<%!static class CheckResult {
		String add = null;
		String timeDiff;
		CheckResult(String add) {
			this.add = add;
		}
		void check(HttpServletRequest request) {
			if (add != null) {
				try {
					URL url = new URL("http://" + add + request.getRequestURI() + "?action=time");
					long startTime = System.currentTimeMillis();
					HttpURLConnection connection = (HttpURLConnection) url.openConnection();
					long endTime = System.currentTimeMillis();
					int response_code = connection.getResponseCode();
					if (response_code == HttpURLConnection.HTTP_OK) {
						InputStream in = connection.getInputStream();
						BufferedReader reader = new BufferedReader(new InputStreamReader(in, "UTF-8"));
						String line = null;
						String content = "";
						while ((line = reader.readLine()) != null) {
							content += line;
						}
						long remoteTime = Long.parseLong(content);
						long diff = (endTime - startTime) / 2 + startTime - remoteTime;
						timeDiff = diff + "毫秒";
						if (diff < -300000 || diff > 300000) {
							timeDiff = "<span style=\"color: red\">" + timeDiff + "</div>";
						}
					}
				} catch (Exception e) {
					timeDiff = "<div class=\"error\">" + e.getMessage() + "</div>";
				}
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

.error {
	background-color: mistyrose;
	border: 1px solid red;
}
</style>
</head>
<body>
	<h2>集群配置检测工具</h2>
	<label for="servers">请输入服务节点地址</label>
	<br>
	<textarea name="servers" rows="4" cols="24" id="servers">127.0.0.1:28080
127.0.0.1:28081</textarea>
	<button id="check">检测</button>

	<div id="msg"></div>

	<script src="jquery.min.js"></script>
	<script type="text/javascript">
		$("#check").click(function() {
			$.post("?action=check", {
				servers : $("#servers").val()
			}, function(data) {
				$("#msg").html(data);
			})
		});
	</script>
</body>
</html>