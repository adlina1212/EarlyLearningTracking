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

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.10.0/dist/umd/popper.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.0/dist/js/bootstrap.min.js"></script>
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">

    <style>
        body {
            background-color: #f7f9fc;
            font-family: 'Arial', sans-serif;
            color: #333;
            margin: 0;
        }
        .sidebar {
            position: fixed;
            height: 100vh;
            width: 210px;
            background-color: #a1c6ea;
            color: white;
            padding: 20px;
            box-shadow: 2px 0 10px rgba(0, 0, 0, 0.1);
        }
        .sidebar h2 {
            font-size: 1.8em;
            margin-bottom: 30px;
            font-weight: bold;
        }
        .sidebar a {
            color: white;
            font-size: 1.2em;
            padding: 12px;
            text-decoration: none;
            display: block;
            margin-bottom: 20px;
            border-radius: 8px;
            transition: background-color 0.3s ease;
        }
        .sidebar a:hover {
            background-color: #007bff;
        }
        .main-content {
            margin-left: 240px;
            padding: 30px;
        }
        .card {
            border-radius: 12px;
            box-shadow: 0px 4px 8px rgba(0, 0, 0, 0.1);
            background-color: white;
            margin-bottom: 30px;
        }
        .card h2 {
            font-size: 1.5em;
            font-weight: bold;
        }
        .btn-add-child, .btn-logout {
            padding: 12px 18px;
            border-radius: 25px;
            font-weight: bold;
        }
        .btn-add-child {
            background-color: #28a745;
            color: white;
        }
        .btn-logout {
            background-color: #dc3545;
            color: white;
        }
        .btn-add-child:hover{
            background-color: #218828;
        }
        table th, table td {
            padding: 15px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        table th {
            background-color: #58a6d1;
            color: white;
        }
        table tr:nth-child(even) {
            background-color: #f9f9f9;
        }
        table tr:hover {
            background-color: #f1f1f1;
        }
        .table-container {
            max-width: 100%;
            overflow-x: auto;
        }
        #progressChart {
            max-width: 100%;
            height: 400px;
        }
    </style>
</head>
<body>

<div class="sidebar">
    <h2>Parent Dashboard</h2>
    <nav>
        <a href="parentDashboard">Home</a>
        <a href="profile">Profile</a>
        <a href="logout">Logout</a>
    </nav>
</div>

<div class="main-content">
    <header class="header d-flex justify-content-between align-items-center mb-4">
        <h1>Welcome, Parent</h1>
        <div>
            <a href="registerChild.jsp" class="btn btn-success btn-add-child">+ Register Child</a>
            <button onclick="window.location.href='logout'" class="btn btn-danger btn-logout">Logout</button>
        </div>
    </header>

    <% if (childrenList != null && !childrenList.isEmpty()) { %>
        <input type="hidden" id="studentId" value="<%= childrenList.get(0).getId() %>" />
    <% } %>

    <div class="content">
        <div class="card">
            <div class="card-body">
                <h2>Your Children</h2>
                <% if (childrenList != null && !childrenList.isEmpty()) { %>
                    <div class="table-container">
                        <table class="table table-striped">
                            <thead>
                                <tr>
                                    <th>Full Name</th>
                                    <th>Date of Birth</th>
                                    <th>Gender</th>
                                    <th>Allergies</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (DocumentSnapshot child : childrenList) { %>
                                    <tr>
                                        <td><%= child.getString("fullName") %></td>
                                        <td><%= child.getString("dob") %></td>
                                        <td><%= child.getString("gender") %></td>
                                        <td><%= child.getString("allergies") != null ? child.getString("allergies") : "-" %></td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                <% } else { %>
                    <p>You have not registered any children yet.</p>
                <% } %>
            </div>
        </div>

        <div class="card">
            <div class="card-body">
                <h2>Progress Overview</h2>
                <div class="mb-3">
                    <label for="datePicker" class="form-label">Select Date:</label>
                    <input type="date" id="datePicker" name="datePicker" class="form-control" required>
                </div>
                <button onclick="loadChartData();" class="btn btn-primary">Load Progress</button>
                <div id="chartsContainer" class="chart-container mt-4"></div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
    let pieInstance = null;

    function getBarColors(values) {
        return values.map(value => {
            if (value <= 2) return 'rgba(255, 99, 132, 0.7)';
            if (value === 3) return 'rgba(255, 206, 86, 0.7)';
            return 'rgba(75, 192, 192, 0.7)';
        });
    }

    function loadChartData() {
        const date = document.getElementById('datePicker').value;
        const studentId = document.getElementById('studentId').value;

        if (!date) {
            alert("Please select a date.");
            return;
        }

        fetch('chartData?date=' + date + '&studentId=' + studentId)
            .then(response => response.json())
            .then(result => {
                const barData = result.barChart;
                const pieData = result.pieChart;
                const container = document.getElementById('chartsContainer');
                container.innerHTML = "";

                barData.forEach((activity, index) => {
                    const literacyLabels = Object.keys(activity.literacy || {});
                    const literacyValues = Object.values(activity.literacy || {});
                    const physicalLabels = Object.keys(activity.physical || {});
                    const physicalValues = Object.values(activity.physical || {});

                    const activityTitle = document.createElement('h4');
                    activityTitle.textContent = `Activity: ${activity.activityName}`;
                    container.appendChild(activityTitle);

                    if (literacyLabels.length > 0) {
                        const literacyCanvas = document.createElement('canvas');
                        literacyCanvas.id = `literacyChart_${index}`;
                        container.appendChild(literacyCanvas);
                        new Chart(literacyCanvas.getContext('2d'), {
                            type: 'bar',
                            data: {
                                labels: literacyLabels,
                                datasets: [{
                                    label: 'Literacy Progress',
                                    data: literacyValues,
                                    backgroundColor: getBarColors(literacyValues),
                                    borderColor: 'rgba(0,0,0,0.7)',
                                    borderWidth: 1
                                }]
                            },
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
                    }

                    if (physicalLabels.length > 0) {
                        const physicalCanvas = document.createElement('canvas');
                        physicalCanvas.id = `physicalChart_${index}`;
                        container.appendChild(physicalCanvas);
                        new Chart(physicalCanvas.getContext('2d'), {
                            type: 'bar',
                            data: {
                                labels: physicalLabels,
                                datasets: [{
                                    label: 'Physical Progress',
                                    data: physicalValues,
                                    backgroundColor: getBarColors(physicalValues),
                                    borderColor: 'rgba(0,0,0,0.7)',
                                    borderWidth: 1
                                }]
                            },
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
                    }
                });

                if (Object.keys(pieData).length > 0) {
                    const pieContainer = document.createElement('div');
                    pieContainer.style.marginTop = "50px";

                    const pieTitle = document.createElement('h3');
                    pieTitle.textContent = "Time Duration Per Activity";
                    pieContainer.appendChild(pieTitle);

                    const pieCanvas = document.createElement('canvas');
                    pieCanvas.id = "activityTimePieChart";
                    pieCanvas.width = 400;
                    pieCanvas.height = 200;
                    pieContainer.appendChild(pieCanvas);

                    container.appendChild(pieContainer);

                    const ctx = pieCanvas.getContext('2d');
                    if (pieInstance) pieInstance.destroy();
                    pieInstance = new Chart(ctx, {
                        type: 'pie',
                        data: {
                            labels: Object.keys(pieData),
                            datasets: [{
                                label: 'Time Duration by Activity',
                                data: Object.values(pieData),
                                backgroundColor: ['#FF6384', '#36A2EB', '#FFCE56', '#4BC0C0', '#9966FF']
                            }]
                        },
                        options: {
                            responsive: true,
                            plugins: {
                                legend: {
                                    position: 'bottom'
                                }
                            }
                        }
                    });
                }
            })
            .catch(error => {
                console.error("Error loading chart data:", error);
                alert("Failed to load chart data.");
            });
    }
</script>
</body>
</html>
