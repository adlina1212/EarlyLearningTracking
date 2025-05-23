<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Activity Summary</title>
    <link rel="stylesheet" href="css/dashboard.css">
    <style>
        .main-content { margin-left: 250px; padding: 30px; }
        .summary-box { background-color: #f9f9f9; padding: 20px; border-radius: 10px; }
        .summary-box p { font-size: 16px; margin-bottom: 10px; }
        form { margin-top: 20px; }
        label { display: block; margin-top: 15px; }
        textarea, select {
            width: 100%;
            padding: 10px;
            border-radius: 5px;
            border: 1px solid #ccc;
        }
        button {
            margin-top: 20px;
            padding: 10px 20px;
            background-color: #28a745;
            color: white;
            border: none;
            border-radius: 5px;
        }
        button:hover { background-color: #218838; }
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
    <h1>Activity Summary</h1>
    <div class="summary-box">
        <p><strong>Student:</strong> ${studentName}</p>
        <p><strong>Activity:</strong> ${activityName}</p>
        <p><strong>Description:</strong> ${activityDescription}</p>
        <p><strong>Date:</strong> ${activityDate}</p>
    </div>

    <form action="submitActivitySummary" method="post">
        <input type="hidden" name="studentId" value="${param.studentId}" />
        <input type="hidden" name="activityId" value="${param.activityId}" />

        <label for="timeToComplete">Time to Complete:</label>
        <select name="timeToComplete" id="timeToComplete" required>
            <option value="">-- Select Duration --</option>
            <option value="5 minutes">5 minutes</option>
            <option value="10 minutes">10 minutes</option>
            <option value="15 minutes">15 minutes</option>
            <option value="20+ minutes">20+ minutes</option>
        </select>

        <label for="teacherComment">Teacher's Comment:</label>
        <textarea name="teacherComment" id="teacherComment" rows="4" placeholder="Write your observation here..." required></textarea>

        <button type="submit">Submit Summary</button>
    </form>
</div>
</body>
</html>
