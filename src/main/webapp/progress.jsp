<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%
    String activityId = request.getParameter("activityId");
    String studentId = request.getParameter("studentId");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Assessment Progress</title>
    <link rel="stylesheet" type="text/css" href="css/physicalProgress.css">
</head>
<body>

<div class="dashboard">
    <h1>Assessment Page</h1>

    <div class="student-info">
            <p><strong>Student Name:</strong> ${fullName}</p>
            <p><strong>Student Age:</strong> ${age}<strong> months</strong></p>
            <p><strong>Date:</strong> 
                <input type="date" name="assessmentDate" value="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>">
            </p>
    </div>


    <form action="submitProgress" method="POST">
        <input type="hidden" name="studentId" value="<%= studentId %>" />
        <input type="hidden" name="activityId" value="<%= activityId %>" />

        <c:set var="focusesAsString" value="${fn:join(focuses, ',')}" />

        <c:if test="${fn:contains(focusesAsString, 'literacy')}">
            <h2>Language, Communication and Early Literacy</h2>
            <table border="1">
                <tr>
                    <th>Criteria</th>
                        <th>Not Yet</th>
                        <th>Just Starting</th>
                        <th>Getting There</th>
                        <th>Doing Well</th>
                        <th>Excellent</th>
                </tr>
                <c:forEach var="criteria" items="${literacyList}">
                    <tr>
                        <td>${criteria}</td>
                        <td><input type="radio" name="literacy_${fn:escapeXml(criteria)}" value="1" required></td>
                        <td><input type="radio" name="literacy_${fn:escapeXml(criteria)}" value="2"></td>
                        <td><input type="radio" name="literacy_${fn:escapeXml(criteria)}" value="3"></td>
                        <td><input type="radio" name="literacy_${fn:escapeXml(criteria)}" value="4"></td>
                        <td><input type="radio" name="literacy_${fn:escapeXml(criteria)}" value="5"></td>
                    </tr>
                </c:forEach>

            </table>
        </c:if>


        <c:if test="${fn:contains(focusesAsString, 'physical')}">
            <h2>Physical and Psychomotor</h2>
            <table border="1">
                <tr>
                    <th>Criteria</th>
                        <th>Not Yet</th>
                        <th>Just Starting</th>
                        <th>Getting There</th>
                        <th>Doing Well</th>
                        <th>Excellent</th>
                </tr>
                <c:forEach var="criteria" items="${psychomotorList}">
                    <tr>
                        <td>${criteria}</td>
                        <td><input type="radio" name="physical_${fn:escapeXml(criteria)}" value="1" required></td>
                        <td><input type="radio" name="physical_${fn:escapeXml(criteria)}" value="2"></td>
                        <td><input type="radio" name="physical_${fn:escapeXml(criteria)}" value="3"></td>
                        <td><input type="radio" name="physical_${fn:escapeXml(criteria)}" value="4"></td>
                        <td><input type="radio" name="physical_${fn:escapeXml(criteria)}" value="5"></td>
                    </tr>
                </c:forEach>
            </table>
        </c:if>

        <div class="summary-box">
        <p><strong>Activity:</strong> ${activityName}</p>
        <p><strong>Description:</strong> ${activityDescription}</p>
        <p><strong>Date:</strong> ${activityDate}</p>
        </div>

        <label for="teacherComment">Teacher Comment:</label>
        <textarea name="teacherComment" id="teacherComment" rows="4" placeholder="Write your observation here..." required></textarea>

        <label for="timeToComplete">Time to Complete:</label>
        <input type="text" name="timeToComplete" />

        <button type="submit">Submit Assessment</button>
    </form>
</div>

</body>
</html>
