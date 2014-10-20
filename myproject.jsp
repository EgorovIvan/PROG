<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.google.appengine.api.users.User" %>
<%@ page import="com.google.appengine.api.users.UserService" %>
<%@ page import="com.google.appengine.api.users.UserServiceFactory" %>
<%@ page import="java.util.List" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="com.google.appengine.api.datastore.DatastoreService" %>
<%@ page import="com.google.appengine.api.datastore.DatastoreServiceFactory" %>
<%@ page import="com.google.appengine.api.datastore.Entity" %>
<%@ page import="com.google.appengine.api.datastore.FetchOptions" %>
<%@ page import="com.google.appengine.api.datastore.Key" %>
<%@ page import="com.google.appengine.api.datastore.KeyFactory" %>
<%@ page import="com.google.appengine.api.datastore.Query" %>
<%@ page import="java.util.*, java.text.*" %>

<html>
<head>
    <link type="text/css" rel="stylesheet" href="/stylesheets/main.css"/>
</head>

<body>

<%
    String myprojectName = request.getParameter("myprojectName");
    if (myprojectName == null) {
    	myprojectName = "default";
    }
    pageContext.setAttribute("myprojectName", myprojectName);
    UserService userService = UserServiceFactory.getUserService();
    User user = userService.getCurrentUser();
    if (user != null) {
        pageContext.setAttribute("user", user);
%>

<p>Hello, ${fn:escapeXml(user.nickname)}! (You can
    <a href="<%= userService.createLogoutURL(request.getRequestURI()) %>">sign out</a>.)</p>
<%
} else {
%>
<p>Hello!
    <a href="<%= userService.createLoginURL(request.getRequestURI()) %>">Sign in</a>
    to include your name with greetings you post.</p>
<%
    }
%>
<%!
  String getFormattedDate (){
     SimpleDateFormat sdf = new SimpleDateFormat ("dd.MM.yyyy hh:mm:ss");
     return sdf.format (new Date ());
  }
%>
<%
    DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
    Key myprojectKey = KeyFactory.createKey("MyProject", myprojectName);
    // Run an ancestor query to ensure we see the most up-to-date
    // view of the Greetings belonging to the selected MyProject.
    Query query = new Query("Greeting", myprojectKey).addSort("date", Query.SortDirection.DESCENDING);
    List<Entity> greetings = datastore.prepare(query).asList(FetchOptions.Builder.withLimit(5));
    if (greetings.isEmpty()) {
%>
<p>MyProject '${fn:escapeXml(myprojectName)}' has no messages.</p>
<%

} else {
%>
<p>Messages in MyProject '${fn:escapeXml(myprojectName)}'.</p>
<%
    for (Entity greeting : greetings) {
        pageContext.setAttribute("greeting_content",
                greeting.getProperty("content"));
        if (greeting.getProperty("user") == null) {
%>
<p>An anonymous person wrote:</p>
<%
} else {
    pageContext.setAttribute("greeting_user",
            greeting.getProperty("user"));
%>
<p><b>${fn:escapeXml(greeting_user.nickname)}</b> wrote:</p>
<%
    }
%>
<blockquote>${fn:escapeXml(greeting_content)}</blockquote>
<%= getFormattedDate () %>

<%
        }
    }
%>

<form action="/sign" method="post">
    <div><textarea name="content" rows="3" cols="60"></textarea></div>
    <div><input type="submit" value="Вывод сообщения времени и даты"/></div>
    <input type="hidden" name="myprojectName" value="${fn:escapeXml(myprojectName)}"/>
</form>

<form action="/myproject.jsp" method="get">
    <div><input type="text" name="myprojectName" value="${fn:escapeXml(myprojectName)}"/></div>
    <div><input type="submit" value="Имя пользователя"/></div>
</form>

</body>
</html>