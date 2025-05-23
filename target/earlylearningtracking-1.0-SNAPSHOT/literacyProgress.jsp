<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%
    String activityId = request.getParameter("activityId");
%>

<!DOCTYPE html>
<html>
<head>
    <title>Language, Communication and Early Literacy Assessment</title>
    <link rel="stylesheet" type="text/css" href="css/physicalProgress.css">
</head>
<body>

<div class="dashboard">
    <header class="header">
        <h1>ASSESSMENT</h1>
    </header>

    <section class="assessment-section">
        <h2>Language, Communication and Early Literacy</h2>

        <div class="student-info">
            <p><strong>Student Name:</strong> ${fullName}</p>
            <p><strong>Student Age:</strong> ${age}<strong> months</strong></p>
            <p><strong>Date:</strong> 
                <input type="date" name="assessmentDate" value="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>">
            </p>
        </div>

        <form action="submitLiteracyProgress" method="POST">
            <input type="hidden" name="studentId" value="${studentId}">
            <input type="hidden" name="activityId" value="${activityId}">

            
            <table class="assessment-table">
                <thead>
                    <tr>
                        <th>Criteria</th>
                        <th>Not Yet</th>
                        <th>Just Starting</th>
                        <th>Getting There</th>
                        <th>Doing Well</th>
                        <th>Excellent</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="criteria" items="${literacyList}">
                        <tr>
                            <td>${criteria}</td>
                            <td><input type="radio" name="progress_${fn:escapeXml(criteria)}" value="1" required></td>
                            <td><input type="radio" name="progress_${fn:escapeXml(criteria)}" value="2"></td>
                            <td><input type="radio" name="progress_${fn:escapeXml(criteria)}" value="3"></td>
                            <td><input type="radio" name="progress_${fn:escapeXml(criteria)}" value="4"></td>
                            <td><input type="radio" name="progress_${fn:escapeXml(criteria)}" value="5"></td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>

            <div class="submit-button">
                <button type="submit">Submit</button>
            </div>
        </form>

    </section>
</div>

</body>
</html>
