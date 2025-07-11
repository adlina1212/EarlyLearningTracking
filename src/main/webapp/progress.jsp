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
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" type="text/css" href="css/physicalProgress.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins&display=swap" rel="stylesheet">
<style>
        body {
            margin: 0;
            font-family: 'Poppins', sans-serif;
            background-color: #f6f3fc;
        }

        /* Navigation */
        .top-nav {
            background: linear-gradient(to right, #a993f5, #c3b5f8);
            padding: 20px 40px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            color: white;
        }

        .logo {
            font-size: 24px;
            font-weight: bold;
            color: white;
        }

        .logo span {
            color: #ffffff;
        }

        .nav-links {
            list-style: none;
            display: flex;
            gap: 25px;
            margin: 0;
            padding: 0;
        }

        .nav-links a {
            color: white;
            text-decoration: none;
            font-size: 16px;
        }

        .nav-links a:hover {
            text-decoration: underline;
        }

        .dashboard {
            max-width: 1000px;
            margin: 40px auto;
            padding: 20px;
            background: #fff;
            border-radius: 12px;
            box-shadow: 0 6px 12px rgba(0,0,0,0.05);
        }

        h1, h2 {
            color: #5e3dad;
            margin-top: 30px;
        }

        .student-info, .summary-box {
            background-color: #f9f7fe;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 20px;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
            background: white;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 2px 6px rgba(0,0,0,0.05);
        }

        table th {
            background-color: #a57ffa;
            color: white;
            padding: 12px;
        }

        table td {
            padding: 12px;
            text-align: center;
            border-bottom: 1px solid #eee;
        }

        table tr:nth-child(even) {
            background-color: #f2eafa;
        }

        input[type="radio"] {
            transform: scale(1.2);
        }

        textarea, select, input[type="text"], input[type="date"] {
            width: 100%;
            padding: 10px;
            margin-top: 8px;
            border-radius: 6px;
            border: 1px solid #ccc;
            font-family: 'Poppins', sans-serif;
        }

        label {
            margin-top: 20px;
            display: block;
            font-weight: 500;
            color: #333;
        }

        button[type="submit"] {
            margin-top: 30px;
            background-color: #a57ffa;
            color: white;
            padding: 12px 20px;
            border: none;
            border-radius: 8px;
            font-weight: bold;
            font-size: 16px;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }

        button[type="submit"]:hover {
            background-color: #8e66f4;
        }

        .justify-text {
            text-align: justify;
        }
    </style>
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
                        <td class="justify-text">${criteria}</td>
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
                        <td class="justify-text">${criteria}</td>
                        <td><input type="radio" name="physical_${fn:escapeXml(criteria)}" value="1" required></td>
                        <td><input type="radio" name="physical_${fn:escapeXml(criteria)}" value="2"></td>
                        <td><input type="radio" name="physical_${fn:escapeXml(criteria)}" value="3"></td>
                        <td><input type="radio" name="physical_${fn:escapeXml(criteria)}" value="4"></td>
                        <td><input type="radio" name="physical_${fn:escapeXml(criteria)}" value="5"></td>
                    </tr>
                </c:forEach>
            </table>
        </c:if>

        <h2>Activity Summary</h2>
        <div class="summary-box">
        <p><strong>Activity:</strong> ${activityName}</p>
        <p><strong>Description:</strong> ${activityDescription}</p>
        <p><strong>Date:</strong> ${activityDate}</p>
        </div>

        <label for="teacherComment">Teacher Comment:</label>
        <textarea name="teacherComment" id="teacherComment" rows="4" placeholder="Write your observation here..." required></textarea>

        <label for="timeToComplete">Time to Complete (in minutes):</label>
        <select name="timeToComplete" id="timeToComplete" required>
            <option value="">-- Select Duration --</option>
            <option value="5">5 minutes</option>
            <option value="10">10 minutes</option>
            <option value="15">15 minutes</option>
            <option value="20">20+ minutes</option>
        </select>

        <button type="submit">Submit Assessment</button>
    </form>
</div>

</body>
</html>
