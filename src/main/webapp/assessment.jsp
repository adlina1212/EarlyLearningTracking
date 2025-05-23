<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, java.text.*" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Assessment</title>
    <link rel="stylesheet" href="css/dashboard.css">
    <style>
        .student-list { list-style: none; padding: 0; }
        .student-list li { margin: 10px 0; padding: 8px; border: 1px solid #ccc; border-radius: 5px; }
        .present a { color: blue; text-decoration: underline; cursor: pointer; }
        .absent { color: grey; pointer-events: none; }
        .scale-select { margin-left: 20px; }

        #showFormBtn {
            background-color: #007bff;
            color: white;
            padding: 8px 12px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }

        #showFormBtn:hover {
            background-color: #0056b3;
        }

        #activityFormContainer {
            display: none;
            border: 1px solid #ccc;
            padding: 20px;
            margin-top: 20px;
            border-radius: 10px;
            background-color: #f9f9f9;
        }

        form label {
            display: block;
            margin-top: 10px;
        }

        form input, form textarea, form select {
            width: 100%;
            padding: 8px;
            margin-top: 4px;
        }

        form button[type="submit"] {
            margin-top: 15px;
            background-color: #28a745;
            color: white;
            padding: 10px 14px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }

        form button[type="submit"]:hover {
            background-color: #218838;
        }
        
        table {
            font-family: Arial, sans-serif;
        }

        table thead {
            background-color: #007bff;
            color: white;
        }

        table tbody tr:nth-child(even) {
            background-color: #f2f2f2;
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
    <div style="display: flex; justify-content: space-between; align-items: center;">
        <h1>Activity List</h1>
        <button id="showFormBtn">+ Add Activity</button>
    </div>

    <%
        List<Map<String, Object>> activityList = (List<Map<String, Object>>) request.getAttribute("activities");
    %>

    <div>
        <% if (activityList == null || activityList.isEmpty()) { %>
            <p>No activity found.</p>
        <% } else { %>
            <table border="1" cellpadding="10" cellspacing="0" style="width: 100%; border-collapse: collapse;">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Activity Name</th>
                        <th>Description</th>
                        <th>Date</th>
                        <th>Focus</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
        <%
            String editingId = request.getParameter("editingId");
            int index = 1;
            for (Map<String, Object> activity : activityList) {
                String activityId = activity.get("id").toString();
                boolean isEditing = activityId.equals(editingId);
        %>
        <tr>
            <td><%= index++ %></td>

            <% if (isEditing) { %>
                <form action="updateActivity" method="POST">
                    <input type="hidden" name="activityId" value="<%= activityId %>">
                    <td><input type="text" name="activityName" value="<%= activity.get("name") %>" required></td>
                    <td><input type="text" name="activityDescription" value="<%= activity.get("description") %>" required></td>
                    <td><input type="date" name="activityDate" value="<%= activity.get("date") %>" required></td>
                    <td colspan="2">
                        <select name="focus">
                            <option value="literacy">Literacy</option>
                            <option value="physical">Physical</option>
                        </select>
                        <button type="submit">Save</button>
                        <a href="assessment.jsp">Cancel</a>
                    </td>
                </form>
            <% } else { %>
                <td><%= activity.get("name") %></td>
                <td><%= activity.get("description") %></td>
                <td><%= activity.get("date") %></td>
                <td>
                    <form method="GET" action="selectStudent">
                        <input type="hidden" name="activityId" value="<%= activityId %>" />

                        <label><input type="checkbox" name="focuses" value="literacy"> Literacy</label>
                        <label><input type="checkbox" name="focuses" value="physical"> Physical</label>
                        
                        <button type="submit">Load Students</button>
                    </form>
                </td>
                <td>
                    <form method="GET" action="assessment.jsp" style="display:inline;">
                        <input type="hidden" name="editingId" value="<%= activityId %>">
                        <button type="submit">Edit</button>
                    </form>
                    <form action="deleteActivity" method="POST" style="display:inline;" onsubmit="return confirm('Are you sure you want to delete this activity?');">
                        <input type="hidden" name="activityId" value="<%= activityId %>">
                        <button type="submit">Delete</button>
                    </form>
                </td>
            <% } %>
        </tr>
        <% } %>
                </tbody>
            </table>            
        <% } %>
    </div>

    <div id="activityFormContainer">
        <h2>Add New Activity</h2>
        <form action="submitActivity" method="post">
            <label for="activityDate">Date:</label>
            <input type="date" id="activityDate" name="activityDate" required>

            <label for="activityName">Activity Name:</label>
            <input type="text" id="activityName" name="activityName" required>

            <label for="activityDescription">Activity Description:</label>
            <textarea id="activityDescription" name="activityDescription" rows="3" required></textarea>

            <button type="submit">Submit Activity</button>
        </form>
    </div>

    <hr>
</div>

<script>
    document.addEventListener("DOMContentLoaded", function () {
        const showFormBtn = document.getElementById("showFormBtn");
        const formContainer = document.getElementById("activityFormContainer");

        showFormBtn.addEventListener("click", () => {
            formContainer.style.display = formContainer.style.display === "none" ? "block" : "none";
        });
    });
</script>

</body>
</html>
