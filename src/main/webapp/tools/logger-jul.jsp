<%@ page import="java.util.*,java.util.logging.*"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
Handlers：<%
    Handler[] handlers = LogManager.getLogManager().getLogger("")
            .getHandlers();
    for (int i = 0; i < handlers.length; i++) {
%><%=handlers[i].getClass().getName()%>
<%
    }
%>
