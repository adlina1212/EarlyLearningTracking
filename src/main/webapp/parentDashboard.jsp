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

    <!-- Bootstrap CSS (Bootstrap 5) -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.0/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Optional Bootstrap JavaScript -->
    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.10.0/dist/umd/popper.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.0/dist/js/bootstrap.min.js"></script>

    <!-- Material Icons (optional for icons) -->
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">

    <!-- Custom CSS -->
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
            width: 220 px;
            background-color: #a1c6ea;
            color: white;
            padding: 20px;
            box-shadow: 2px 0 10px rgba(0, 0, 0, 0.1);
            transition: all 0.3s ease;
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
        header{
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        header h1{
            font-size: 2.5em;
            color: #333;
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
        /* Table Styles */
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

        /* Progress Chart */
        #progressChart {
            max-width: 100%;
            height: 400px;
        }
    </style>
</head>
<body>

<!-- Sidebar -->
<div class="sidebar">
    <h2>Parent Dashboard</h2>
    <nav>
        <a href="parentDashboard">Home</a>
        <a href="profile">Profile</a>
        <a href="logout">Logout</a>
    </nav>
</div>

<!-- Main Content Area -->
<div class="main-content">
    <!-- Header Section -->
    <header class="header d-flex justify-content-between align-items-center mb-4">
        <h1>Welcome, Parent</h1>
        <div>
            <a href="registerChild.jsp" class="btn btn-success btn-add-child">+ Register Child</a>
            <button onclick="window.location.href='logout'" class="btn btn-danger btn-logout">Logout</button>
        </div>
    </header>

    <% if (childrenList != null && !childrenList.isEmpty()) { %>
        <%-- Assuming you're showing only one child's data at a time for now --%>
        <input type="hidden" id="studentId" value="<%= childrenList.get(0).getId() %>" />
    <% } %>

    <!-- Display Children's Information -->
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

        <!-- Progress Overview Section -->
        <div class="card">
            <div class="card-body">
                <h2>Progress Overview</h2>
                <div class="mb-3">
                    <label for="datePicker" class="form-label">Select Date:</label>
                    <input type="date" id="datePicker" name="datePicker" class="form-control" required>
                </div>
                <button onclick="loadChartData(); loadPieChartData();" class="btn btn-primary">Load Progress</button>

                <!-- Separate Chart Containers -->
                <div class="chart-container mt-4">
                    <div>
                        <h3>Literacy Progress</h3>
                        <canvas id="literacyChart"></canvas>
                    </div>
                    <div>
                        <h3>Physical Progress</h3>
                        <canvas id="physicalChart"></canvas>
                    </div>
                    <div>
                        <h3 style="margin-top: 40px;">Time Duration Per Activity</h3>
                        <canvas id="activityTimePieChart" width="800" height="400"></canvas>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
    let literacyChartInstance = null;
    let physicalChartInstance = null;
    let pieInstance = null;

    function getBarColors(values) {
        return values.map(value => {
            if (value <= 2) return 'rgba(255, 99, 132, 0.7)';      // red
            if (value === 3) return 'rgba(255, 206, 86, 0.7)';     // yellow
            return 'rgba(75, 192, 192, 0.7)';                      // green
        });
    }

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

                //const labels = [...new Set([...literacyLabels, ...physicalLabels])];

                const literacyCtx = document.getElementById('literacyChart').getContext('2d');
                const physicalCtx = document.getElementById('physicalChart').getContext('2d');

                // Destroy existing charts if they exist
                if (literacyChartInstance) literacyChartInstance.destroy();
                if (physicalChartInstance) physicalChartInstance.destroy();

                literacyChartInstance = new Chart(literacyCtx, {
                    type: 'bar',
                    data: {
                        labels: literacyLabels,
                        datasets: [{
                            label: 'Literacy Progress',
                            data: literacyData,
                            backgroundColor: getBarColors(literacyData),
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

                physicalChartInstance = new Chart(physicalCtx, {
                    type: 'bar',
                    data: {
                        labels: physicalLabels,
                        datasets: [{
                            label: 'Physical Progress',
                            data: physicalData,
                            backgroundColor: getBarColors(physicalData),
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
            })
            .catch(error => {
                console.error("Error fetching chart data:", error);
                alert("Failed to load chart data.");
            });
    }
    function loadPieChartData() {
    const date = document.getElementById('datePicker').value;
    const studentId = '<%= childrenList.get(0).getId() %>'; // or session value

    fetch(`chartPieData?studentId=${studentId}&date=${date}`)
        .then(response => response.json())
        .then(data => {
            console.log("Pie chart data:", data);

            const labels = Object.keys(data);
            const values = Object.values(data);

            const ctx = document.getElementById('activityTimePieChart').getContext('2d');
            if (pieInstance) pieInstance.destroy();
            pieInstance = new Chart(ctx, {
                type: 'pie',
                data: {
                    labels: labels,
                    datasets: [{
                        label: 'Time Duration by Activity',
                        data: values,
                        backgroundColor: [
                            '#FF6384', '#36A2EB', '#FFCE56', '#4BC0C0', '#9966FF'
                        ]
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
        })
        .catch(error => {
            console.error("Error loading pie chart:", error);
        });
}

</script>
</body>
</html>
