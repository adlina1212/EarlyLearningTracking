<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.google.cloud.firestore.*" %>
<%@ page import="java.util.List, java.util.Map" %>
<%@ page import="com.google.cloud.firestore.DocumentSnapshot" %>
<%@ page session="true" %>
<%
    List<DocumentSnapshot> childrenList = (List<DocumentSnapshot>) request.getAttribute("childrenList");
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
    <% if (childrenList != null && !childrenList.isEmpty()) { %>
        <%-- Assuming you're showing only one child's data at a time for now --%>
        <input type="hidden" id="studentId" value="<%= childrenList.get(0).getId() %>" />
    <% } %>


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
            <h2>Progress Overview</h2>
            <label for="datePicker">Select Date:</label>
            <input type="date" id="datePicker" name="datePicker" required>
            <button onclick="loadChartData()">Load Progress</button>

            <canvas id="progressChart" width="800" height="400"></canvas>

        </div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
    let chartInstance = null;

    function loadChartData() {
        const date = document.getElementById('datePicker').value;
        const studentId = document.getElementById('studentId').value;

        console.log("📅 Selected date:", date);
        console.log("🧒 Student ID:", studentId);

        if (!date) {
            alert("Please select a date.");
            return;
        }

        fetch('${pageContext.request.contextPath}/chartData?date=' + date + '&studentId=' + studentId)
            .then(response => response.json())
            .then(data => {
                const literacyLabels = Object.keys(data.literacy || {});
                const literacyData = Object.values(data.literacy || {});

                const physicalLabels = Object.keys(data.physical || {});
                const physicalData = Object.values(data.physical || {});

                const labels = [...new Set([...literacyLabels, ...physicalLabels])];

                const literacyDataset = {
                    label: "Literacy",
                    backgroundColor: "rgba(54, 162, 235, 0.6)",
                    borderColor: "rgba(54, 162, 235, 1)",
                    borderWidth: 1,
                    data: labels.map(label => data.literacy?.[label] || 0)
                };

                const physicalDataset = {
                    label: "Physical",
                    backgroundColor: "rgba(255, 99, 132, 0.6)",
                    borderColor: "rgba(255, 99, 132, 1)",
                    borderWidth: 1,
                    data: labels.map(label => data.physical?.[label] || 0)
                };

                const chartData = {
                    labels: labels,
                    datasets: [literacyDataset, physicalDataset]
                };

                const ctx = document.getElementById('progressChart').getContext('2d');

                // Destroy old chart if exists
                if (chartInstance) chartInstance.destroy();

                chartInstance = new Chart(ctx, {
                    type: 'bar',
                    data: chartData,
                    options: {
                        responsive: true,
                        scales: {
                            y: {
                                beginAtZero: true,
                                min: 0,
                                max: 5,
                                ticks: {
                                    stepSize: 1
                                }
                            }
                        }
                    }
                });
            })
            .catch(error => {
                console.error("Error fetching chart data:", error);
                alert("Failed to load chart data.");
            });
    }
</script>
</body>
</html>
