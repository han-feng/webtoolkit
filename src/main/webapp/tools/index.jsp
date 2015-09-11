<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%!public static boolean checkClass(String className) {
        try {
            Class.forName(className);
        } catch (ClassNotFoundException e) {
            return false;
        }
        return true;
    }%>
<html>
<head>
<style>
li {
	padding: 5px;
}
</style>
</head>
<body>
	<div>
		<strong>Web应用调试工具集</strong> | <a href="http://webtoolkit.coding.io">演示</a>
		| <a href="https://coding.net/u/xcom/p/webtoolkit/git">源码</a> | <a
			href="https://coding.net/u/xcom/p/webtoolkit/topic/all">讨论</a>
	</div>
	<hr>
	<div>
		<ul>
			<li><a href="serverInfo.jsp">应用运行环境信息</a></li>
			<li><a href="logger.jsp">日志工具配置信息</a></li>
			<li><a href="javaResource.jsp">Java资源查找工具</a></li>
			<%
			    if (checkClass("org.xcom.cat.core.ClassloaderAnalysisTool")) {
			%>
			<li><a href="cat.jsp">类加载器分析工具</a> | <a href="classLoader.jsp">简化版</a></li>
			<%
			    } else {
			%>
			<li><a href="classLoader.jsp">类加载器分析工具简化版</a> （完整版本需将 <a
				href="http://repo1.maven.org/maven2/net/coding/xcom/cat-core/0.0.1/cat-core-0.0.1.jar">cat-core-0.0.1.jar</a>
				加入到类路径后可用）</li>
			<%
			    }
			%>
			<li><a href="cluster.jsp">集群会话验证工具</a></li>
			<li><a href="<%=request.getContextPath()%>/filterChainDetector">过滤器链探查工具</a></li>
		</ul>
	</div>
</body>
</html>
