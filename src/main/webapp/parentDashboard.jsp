<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.google.cloud.firestore.*" %>
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
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
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
    <header class="header" style="display: flex; justify-content: space-between; align-items: center;">
        <h1>Welcome, Parent</h1>
        <div>
            <a href="registerChild.jsp" class="btn-add-child">+ Register Child</a>
            <button onclick="window.location.href='logout'" class="btn-logout">Logout</button>
        </div>
    </header>

    <div class="content">
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
        </div>

        <div class="card">
            <h2>View Progress Chart</h2>
            <label for="progressDate">Select Date:</label>
            <input type="date" id="progressDate" name="progressDate" onchange="loadChart(this.value)">
            <canvas id="progressChart" style="max-width: 100%; margin-top: 20px;"></canvas>
        </div>
    </div>
</div>

<script>
async function loadChart(date) {
    if (!date) return;
    const res = await fetch(`chartData?date=${date}`);
    const data = await res.json();

    const labels = Object.keys(data.literacy || {});
    const literacyData = Object.values(data.literacy || {});
    const physicalData = Object.values(data.physical || {});

    const ctx = document.getElementById('progressChart').getContext('2d');
    if (window.myChart) window.myChart.destroy();
    window.myChart = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: labels,
            datasets: [
                {
                    label: 'Literacy',
                    data: literacyData,
                    backgroundColor: 'rgba(54, 162, 235, 0.6)'
                },
                {
                    label: 'Physical',
                    data: physicalData,
                    backgroundColor: 'rgba(255, 99, 132, 0.6)'
                }
            ]
        },
        options: {
            responsive: true,
            plugins: {
                legend: { position: 'top' },
                title: {
                    display: true,
                    text: 'Daily Assessment Scores'
                }
            }
        }
    });
}
</script>

</body>
</html>
