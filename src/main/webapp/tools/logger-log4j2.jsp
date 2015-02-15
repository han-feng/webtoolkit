<%@ page
	import="java.util.*,org.apache.logging.log4j.*,org.apache.logging.log4j.core.*,org.apache.logging.log4j.core.config.*"
	language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%
    //
    org.apache.logging.log4j.spi.LoggerContext context = LogManager
            .getContext();
    if (context instanceof LoggerContext) {
%>
<table border="1">
	<caption>Loggers</caption>
	<tr>
		<th>name</th>
		<th>level</th>
		<th>state</th>
		<th>properties</th>
		<th>appender</th>
	</tr>
	<%
	    //
	        LoggerContext ctx = (LoggerContext) context;
	        for (Iterator itr = ctx.getConfiguration().getLoggers()
	                .values().iterator(); itr.hasNext();) {
	            LoggerConfig logger = (LoggerConfig) itr.next();
	            StringBuilder logNames = new StringBuilder();
	            for (Iterator refsItr = logger.getAppenderRefs().iterator(); refsItr
	                    .hasNext();) {
	                AppenderRef ref = (AppenderRef) refsItr.next();
	                logNames.append(ref.getRef() + "<br>");
	            }
	%>
	<tr>
		<td><%=logger.getName()%></td>
		<td><%=logger.getLevel()%></td>
		<td><%=logger.getState()%></td>
		<td><%=logger.getProperties()%></td>
		<td><%=logNames%></td>
	</tr>
	<%
	    //
	        }
	%>
</table>

<table border="1">
	<caption>Appenders</caption>
	<tr>
		<th>name</th>
		<th>class</th>
	</tr>
	<%
	    //
	        for (Appender appender : ctx.getConfiguration().getAppenders()
	                .values()) {
	%>
	<tr>
		<td><%=appender.getName()%></td>
		<td><%=appender.getClass().getName()%></td>
	</tr>
	<%
	    //
	        }
	    }
	%>
</table>
