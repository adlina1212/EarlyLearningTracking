<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Select Student for Assessment</title>
    
    <!-- Bootstrap 5 CSS (for modern design) -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.0/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <!-- Material Icons (optional for icons) -->
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">

    <!-- Optional Bootstrap JavaScript -->
    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.10.0/dist/umd/popper.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.0/dist/js/bootstrap.min.js"></script>

    <!-- Custom CSS -->
     <style>
        body {
            background-color: #f6f3fc;
            font-family: 'Segoe UI', sans-serif;
            margin: 0;
            padding: 0;
        }

        /* Top Navigation */
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
            color: #fdfdfd;
        }

        .nav-links {
            list-style: none;
            display: flex;
            gap: 25px;
        }

        .nav-links a {
            color: white;
            text-decoration: none;
            font-size: 16px;
        }

        .nav-links a:hover {
            text-decoration: underline;
        }

        .container {
            max-width: 1000px;
            margin: 40px auto;
            background-color: #ffffff;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 6px 12px rgba(0,0,0,0.05);
        }

        h1, h2 {
            color: #5e3dad;
        }

        button, input[type="submit"] {
            background-color: #a57ffa;
            color: white;
            padding: 8px 14px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }

        button:hover, input[type="submit"]:hover {
            background-color: #8e66f4;
        }

        #activityFormContainer {
            background-color: #f9f7fe;
            padding: 20px;
            border-radius: 12px;
            margin-top: 20px;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }

        thead {
            background-color: #a57ffa;
            color: white;
        }

        td, th {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }

        tbody tr:nth-child(even) {
            background-color: #f2eafa;
        }

        form input, form textarea, form select {
            width: 100%;
            padding: 8px;
            margin-top: 4px;
            border: 1px solid #ccc;
            border-radius: 6px;
        }

        .top-section {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .edit-btns form {
            display: inline-block;
        }

        .edit-btns button {
            margin-right: 5px;
        }
        .student-container {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
        gap: 20px;
        margin-top: 30px;
        padding: 0 20px;
    }

    .student-card {
        background-color: #ffffff;
        border-radius: 10px;
        box-shadow: 0 4px 10px rgba(0,0,0,0.05);
        padding: 20px;
        text-align: center;
        transition: transform 0.2s ease;
    }

    .student-card:hover {
        transform: translateY(-3px);
    }

    .student-name {
        font-size: 18px;
        font-weight: 600;
        color: #5e3dad;
        margin-bottom: 15px;
    }

    .student-btn {
        background-color: #a57ffa;
        color: white;
        border: none;
        padding: 8px 14px;
        border-radius: 6px;
        cursor: pointer;
        transition: background-color 0.3s ease;
    }

    .student-btn:hover {
        background-color: #8e66f4;
    }

    .back-link {
        display: inline-block;
        margin: 30px 40px 10px;
        text-decoration: none;
        color: #5e3dad;
        font-weight: bold;
    }

    .top-bar {
        padding: 0 40px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        flex-wrap: wrap;
        gap: 10px;
    }

    .date-form {
        display: flex;
        gap: 10px;
        align-items: center;
        flex-wrap: wrap;
    }

    .date-form input[type="date"] {
        padding: 6px 10px;
        border: 1px solid #ccc;
        border-radius: 6px;
    }
    </style>
</head>
<body>

<!-- Top Navigation Bar -->
<nav class="top-nav">
    <div class="logo">teacher<span>.</span></div>
    <ul class="nav-links">
        <li><a href="teacherDashboard">Home</a></li>
        <li><a href="profile">Profile</a></li>
        <li><a href="assessment">Assessment</a></li>
        <li><a href="studentReport">Student Report</a></li>
        <li><a href="logout">Logout</a></li>
    </ul>
</nav>

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
        <!-- Student List -->
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
