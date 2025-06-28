<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Teacher Dashboard</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600&display=swap" rel="stylesheet">
    <style>
        body {
            margin: 0;
            padding: 0;
            font-family: 'Poppins', sans-serif;
            background-color: #f8f6fc;
        }

        /* Top Navigation */
        .top-nav {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 20px 50px;
            background: linear-gradient(to right, #b295d9, #c7aefc);
            color: #fff;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
        }

        .top-nav .logo {
            font-size: 24px;
            font-weight: 700;
        }

        .top-nav .logo span {
            color: #fff;
        }

        .nav-links {
            list-style: none;
            display: flex;
            gap: 25px;
            margin: 0;
        }

        .nav-links li a {
            color: white;
            text-decoration: none;
            font-weight: 500;
        }

        .nav-links li a:hover {
            text-decoration: underline;
        }

        .dashboard-container {
            max-width: 1100px;
            margin: 40px auto;
            background: #ffffff;
            padding: 30px;
            border-radius: 20px;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.05);
        }

        .dashboard-container h1 {
            color: #6c4aab;
            margin-bottom: 20px;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }

        table th, table td {
            padding: 12px;
            border-bottom: 1px solid #ddd;
            text-align: left;
        }

        table th {
            background-color: #e6ddf7;
            color: #5c3fa2;
        }

        table tr:nth-child(even) {
            background-color: #f9f5ff;
        }

        button {
            background-color: #b28ed7;
            color: white;
            border: none;
            padding: 12px 20px;
            border-radius: 25px;
            font-weight: bold;
            cursor: pointer;
            margin-top: 20px;
        }

        button:hover {
            background-color: #9f77c6;
        }

        .form-section h2 {
            color: #5c3fa2;
            margin-top: 0;
        }

        label {
            margin-right: 10px;
        }

        @media screen and (max-width: 768px) {
            .top-nav {
                flex-direction: column;
                align-items: flex-start;
                padding: 20px;
            }
            .nav-links {
                flex-direction: column;
                gap: 10px;
                margin-top: 10px;
            }
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

<!-- Main Dashboard Content -->
<div class="dashboard-container">
    <h1>Welcome Teacher</h1>

    <div class="form-section">
        <h2>Student Attendance</h2>
        <button type="button" onclick="markAllPresent()">Mark All Present</button>
        <form action="submitAttendance" method="post">
            <table>
                <thead>
                    <tr>
                        <th>Student Name</th>
                        <th>Present?</th>
                    </tr>
                </thead>
                <tbody>
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
                    <tr>
                        <td colspan="2">No students found.</td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
            <button type="submit">Submit Attendance</button>
        </form>
    </div>
</div>
<script>
    function markAllPresent() {
        const radios = document.querySelectorAll('input[type="radio"][value="yes"]');
        radios.forEach(radio => {
            radio.checked = true;
        });
    }
</script>

</body>
</html>
