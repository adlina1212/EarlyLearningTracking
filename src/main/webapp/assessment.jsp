<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, java.text.*" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Assessment</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body {
            margin: 0;
            padding: 0;
            font-family: 'Poppins', sans-serif;
            background-color: #f8f6fc;
        }

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
        .modal-overlay {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-color: rgba(0,0,0,0.5);
            display: none;
            justify-content: center;
            align-items: center;
            z-index: 1000;
        }

        .modal-box {
            background: #fff;
            padding: 30px;
            width: 90%;
            max-width: 500px;
            border-radius: 12px;
            box-shadow: 0 8px 20px rgba(0,0,0,0.2);
            position: relative;
        }

        .modal-box h2 {
            margin-top: 0;
            color: #5e3dad;
        }

        .modal-box .close-btn {
            position: absolute;
            top: 10px;
            right: 14px;
            font-size: 20px;
            background: none;
            border: none;
            color: #888;
            cursor: pointer;
        }

        .modal-box .close-btn:hover {
            color: #000;
        }
    </style>
</head>
<body>
<!-- Top Navigation -->
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

<div class="container">
    <div class="top-section">
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
            <table >
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
                        <button type="submit" style="background-color: #f05b5b;">Delete</button>
                    </form>
                </td>
            <% } %>
        </tr>
        <% } %>
                </tbody>
            </table>            
        <% } %>
    </div>

    <!-- Popup Modal for Add Activity -->
<div class="modal-overlay" id="activityModal">
    <div class="modal-box">
        <button class="close-btn" onclick="closeModal()">×</button>
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
</div>

    <hr>
</div>

<script>
    const modal = document.getElementById("activityModal");

    document.getElementById("showFormBtn").addEventListener("click", function () {
        modal.style.display = "flex";
    });

    function closeModal() {
        modal.style.display = "none";
    }

    // Optional: Close modal if user clicks outside the modal box
    window.addEventListener("click", function (event) {
        if (event.target === modal) {
            modal.style.display = "none";
        }
    });
</script>

</body>
</html>
