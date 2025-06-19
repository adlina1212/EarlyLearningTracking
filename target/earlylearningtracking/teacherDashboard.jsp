<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Teacher Dashboard</title>
    <link rel="stylesheet" href="css/dashboard.css">
</head>
<body>
<div class="sidebar">
    <h2>Dashboard</h2>
    <nav>
        <a href="teacherDashboard">Home</a>
        <a href="profile">Profile</a>
        <a href="assessment">Assessment</a>
        <a href="studentReport">Student Report</a> <!-- New Link -->
        <a href="logout">Logout</a>
    </nav>
</div>

<div class="main-content">
    <header class="header">
        <h1>Welcome to Your Dashboard</h1>
        <button onclick="window.location.href='logout'">Logout</button>
    </header>

    <div class="content">
        <div class="student-list-box">
            <h2>Student Attendance</h2>

            <form action="submitAttendance" method="post">
                <table border="1" cellpadding="5" cellspacing="0">
                    <tr>
                        <th>Student Name</th>
                        <th>Present?</th>
                    </tr>

                    <%
                        List<Map<String, Object>> students = (List<Map<String, Object>>) request.getAttribute("student");
                        if (students != null && !students.isEmpty()) {
                            for (Map<String, Object> student : students) {
                                String name = (String) student.get("name");
                                String id = (String) student.get("id");
                    %>
                        <tr>
                            <td><%= name %></td>
                            <td>
                                <label>
                                    <input type="radio" name="attendance_<%= id %>" value="yes" required> Yes
                                </label>
                                <label>
                                    <input type="radio" name="attendance_<%= id %>" value="no"> No
                                </label>
                            </td>
                        </tr>
                    <%
                            }
                        } else {
                    %>
                        <tr><td colspan="2">No students found.</td></tr>
                    <%
                        }
                    %>
                </table>

                <br>
                <button type="submit">Submit Attendance</button>
            </form>
        </div>
    </div>
</div>
</body>
</html>
