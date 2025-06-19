<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Select Student for Assessment</title>
    <link rel="stylesheet" href="css/dashboard.css">
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f6f9;
            margin: 0;
            padding: 0;
        }
        .main-content {
            padding: 30px;
            margin-left: 250px;
        }
        .student-container {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
            gap: 20px;
        }
        .student-card {
            background-color: #fff;
            border: 1px solid #ddd;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05);
            transition: box-shadow 0.3s ease;
            text-align: center;
        }
        .student-card:hover {
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        }
        .student-name {
            font-size: 18px;
            font-weight: bold;
            margin-bottom: 10px;
        }
        .student-btn {
            background-color: #007bff;
            color: white;
            border: none;
            padding: 8px 12px;
            border-radius: 5px;
            cursor: pointer;
            transition: 0.3s ease;
        }
        .student-btn:hover {
            background-color: #0056b3;
        }
        .top-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .date-form {
            margin-bottom: 20px;
        }
        .back-link {
            margin-bottom: 20px;
            display: inline-block;
            color: #007bff;
            text-decoration: none;
        }
    </style>
</head>
<body>

<div class="sidebar">
    <h2>Dashboard</h2>
    <nav>
        <a href="teacherDashboard">Home</a>
        <a href="profile">Profile</a>
        <a href="assessment">Assessment</a>
        <a href="logout">Logout</a>
    </nav>
</div>

<div class="main-content">
    <a href="assessment" class="back-link">&larr; Back to Activities</a>

    <div class="top-bar">
        <h1>Select Student for Assessment</h1>
        <form action="selectStudent" method="get" class="date-form">
            <input type="hidden" name="activityId" value="${activityId}" />
            <c:forEach var="focus" items="${focusArray}">
                <input type="hidden" name="focuses" value="${focus}" />
            </c:forEach>
            <input type="date" name="dateSelect" value="${date}" required />
            <button type="submit" class="student-btn">Load Attendance</button>
        </form>
    </div>

    <div class="meta-info">
        

    <div class="student-container">
        <c:choose>
            <c:when test="${not empty studentList}">
                <c:forEach var="student" items="${studentList}">
                    <div class="student-card">
                        <div class="student-name">${student.fullName}</div>
                        <form method="get" action="redirectToAssessment">
                            <input type="hidden" name="studentId" value="${student.studentId}" />
                            <input type="hidden" name="activityId" value="${activityId}" />
                            <c:forEach var="focus" items="${focusArray}">
                                <input type="hidden" name="focuses" value="${focus}" />
                            </c:forEach>
                            <button class="student-btn" type="submit">Select</button>
                        </form>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <p>No present students found for the selected date.</p>
            </c:otherwise>
        </c:choose>
    </div>
</div>

</body>
</html>
