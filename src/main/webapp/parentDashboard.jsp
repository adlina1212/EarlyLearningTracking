<%@ page import="com.google.cloud.firestore.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map" %>
<%@ page import="com.google.cloud.firestore.QueryDocumentSnapshot" %>
<%@ page session="true" %>
<%
    DocumentSnapshot parentDoc = (DocumentSnapshot) request.getAttribute("parentDoc");
    List<QueryDocumentSnapshot> childrenList = (List<QueryDocumentSnapshot>) request.getAttribute("childrenList");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Parent Dashboard</title>
    <link rel="stylesheet" href="css/parentDashboard.css">
</head>
<body>
<div class="sidebar">
    <h2>Dashboard</h2>
    <nav>
        <a href="parentDashboard">Home</a>
        <a href="profile">Profile</a>
        <a href="logout">Logout</a>
    </nav>
</div>

<div class="main-content">
    <header class="header">
        <h1>Welcome, Parent</h1>
        <button onclick="window.location.href='logout'">Logout</button>
    </header>

    <div class="content">
        <div class="card">
            <h2>Parent Information</h2>
            <% if (parentDoc != null && parentDoc.exists()) { %>
                <p><strong>Name:</strong> <%= parentDoc.getString("parentName") %></p>
                <p><strong>Email:</strong> <%= parentDoc.getString("email") %></p>
                <p><strong>Phone:</strong> <%= parentDoc.getString("phone") %></p>
            <% } %>
        </div>

        <div class="card">
            <h2>Your Children</h2>
            <% if (childrenList != null && !childrenList.isEmpty()) { %>
                <table class="styled-table">
                    <tr>
                        <th>Full Name</th>
                        <th>Date of Birth</th>
                        <th>Gender</th>
                        <th>Allergies</th>
                    </tr>
                    <% for (DocumentSnapshot child : childrenList) { %>
                        <tr>
                            <td><%= child.getString("fullName") %></td>
                            <td><%= child.getString("dob") %></td>
                            <td><%= child.getString("gender") %></td>
                            <td><%= child.getString("allergies") != null ? child.getString("allergies") : "-" %></td>
                        </tr>
                    <% } %>
                </table>
            <% } else { %>
                <p>You have not registered any children yet.</p>
            <% } %>

            <a href="registerChild.jsp" class="btn-add-child">+ Register Another Child</a>
        </div>
    </div>
</div>

</body>
</html>
