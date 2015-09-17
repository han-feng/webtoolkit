<%@page import="java.lang.reflect.Field,java.util.*,org.apache.log4j.*"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%
    Field field = null;
    try {
        field = Category.class.getDeclaredField("slf4jLogger");
    } catch (Exception e) {
    }
    if (field != null) {
%>
<font color="red">Log4j 已路由到 Slf4j</font>
<%
    } else {
        try {
            field = Category.class.getDeclaredField("logger");
        } catch (Exception e) {
        }
        if (field != null
                && "org.apache.logging.log4j.core.Logger".equals(field
                        .getType().getName())) {
%>
<font color="red">Log4j 已路由到 Log4j2</font>
<%
    } else {
%>
<table border="1">
	<caption>Loggers</caption>
	<tr>
		<th>name</th>
		<th>level</th>
		<th>effectiveLevel</th>
		<%-- <th>additivity</th>--%>
		<th>appender</th>
	</tr>
	<%
	    Map appenderMap = new LinkedHashMap();
	            Logger logger = Logger.getRootLogger();
	            Enumeration appenders = logger.getAllAppenders();
	            StringBuilder logNames = new StringBuilder();
	            while (appenders.hasMoreElements()) {
	                Appender appender = (Appender) appenders.nextElement();
	                appenderMap.put(appender.getName(), appender);
	                logNames.append(appender.getName() + "<br>");
	            }
	%>
	<tr>
		<td><%=logger.getName()%></td>
		<td><%=logger.getLevel()%></td>
		<td><%=logger.getEffectiveLevel()%></td>
		<%-- <td><%=logger.getAdditivity()%></td> --%>
		<td><%=logNames%></td>
	</tr>
	<%
	    Enumeration currentLoggers = LogManager.getCurrentLoggers();
	            while (currentLoggers.hasMoreElements()) {
	                logger = (Logger) currentLoggers.nextElement();
	                appenders = logger.getAllAppenders();
	                logNames = new StringBuilder();
	                while (appenders.hasMoreElements()) {
	                    Appender appender = (Appender) appenders
	                            .nextElement();
	                    appenderMap.put(appender.getName(), appender);
	                    logNames.append(appender.getName() + "<br>");
	                }
	%>
	<tr>
		<td><%=logger.getName()%></td>
		<td><%=logger.getLevel()%></td>
		<td><%=logger.getEffectiveLevel()%></td>
		<%-- <td><%=logger.getAdditivity()%></td> --%>
		<td><%=logNames%></td>
	</tr>
	<%
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
	    for (Iterator itr = appenderMap.values().iterator(); itr
	                    .hasNext();) {
	                Appender appender = (Appender) itr.next();
	%>
	<tr>
		<td><%=appender.getName()%></td>
		<td><%=appender.getClass().getName()%></td>
	</tr>
	<%
	    }
	%>
</table>
<%
    }
    }
%>
