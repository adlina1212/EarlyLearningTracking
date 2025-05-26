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
        @keyframes gradientAnimation {
            0% {
                background: #ff9a9e;
            }
            50% {
                background: #fad0c4;
            }
            100% {
                background: #fbc2eb;
            }
        }

        body {
            animation: gradientAnimation 10s ease infinite;
            font-family: 'Poppins', sans-serif;
            margin: 0;
            padding: 0;
        }

        .dashboard {
            max-width: 900px;
            margin: auto;
            padding: 20px;
        }

        .student-info, .summary-box {
            background-color: #fff;
            padding: 20px;
            border-radius: 12px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.05);
            margin-bottom: 20px;
        }

        h1, h2 {
            color: #2c3e50;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
            background: #fff;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 6px rgba(0,0,0,0.05);
        }

        table th, table td {
            padding: 10px;
            text-align: center;
            border-bottom: 1px solid #ddd;
        }

        table th {
            background-color: #3498db;
            color: #fff;
        }

        table tr:hover {
            background-color: #f0f8ff;
        }

        input[type="radio"] {
            transform: scale(1.2);
        }

        textarea, input[type="text"], input[type="date"] {
            width: 100%;
            padding: 8px 12px;
            margin-top: 8px;
            border-radius: 6px;
            border: 1px solid #ccc;
        }

        button[type="submit"] {
            background-color: #28a745;
            color: #fff;
            padding: 12px 20px;
            border: none;
            border-radius: 6px;
            font-weight: bold;
            cursor: pointer;
            margin-top: 20px;
        }

        button[type="submit"]:hover {
            background-color: #218838;
        }

        @media (max-width: 600px) {
            .dashboard {
                padding: 10px;
            }
            table {
                font-size: 14px;
            }
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

        <label for="timeToComplete">Time to Complete:</label>
        <select name="timeToComplete" id="timeToComplete" required>
            <option value="">-- Select Duration --</option>
            <option value="5 minutes">5 minutes</option>
            <option value="10 minutes">10 minutes</option>
            <option value="15 minutes">15 minutes</option>
            <option value="20+ minutes">20+ minutes</option>
        </select>

        <button type="submit">Submit Assessment</button>
    </form>
</div>

</body>
</html>
