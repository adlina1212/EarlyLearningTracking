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
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
    
    <style>
        body {
            background: #f7f5fc;
            font-family: 'Poppins', sans-serif;
            margin: 0;
        }

        .top-nav {
            display: flex;
            justify-content: space-between;
            align-items: center;
            background-color: #b79ae0;
            padding: 20px 40px;
            color: white;
            border-bottom-left-radius: 20px;
            border-bottom-right-radius: 20px;
        }

        .logo {
            font-size: 1.8em;
            font-weight: 700;
            color: white;
        }

        .logo span {
            color: #eee1ff;
        }

        .nav-links {
            list-style: none;
            display: flex;
            gap: 25px;
            padding: 0;
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
            max-width: 1200px;
            margin: 30px auto;
            background: white;
            padding: 40px;
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
        }

        h1, h2 {
            color: #5f3e94;
        }

        .discover-btn {
            background-color: #b79ae0;
            color: white;
            padding: 12px 24px;
            border: none;
            border-radius: 25px;
            font-weight: 600;
        }

        .discover-btn:hover {
            background-color: #a87bdc;
        }

        .feature-item span {
            font-size: 48px;
            color: #b79ae0;
        }

        table th {
            background-color: #b79ae0;
        }

        .table-container {
            overflow-x: auto;
        }

        canvas {
            margin-bottom: 40px;
        }
    </style>
</head>
<body>

<div class="top-nav">
    <div class="logo">parent<span>.</span></div>
    <ul class="nav-links">
        <li><a href="parentDashboard">Home</a></li>
        <li><a href="profile">Profile</a></li>
        <li><a href="registerChild.jsp">Add Child</a></li>
        <li><a href="logout">Logout</a></li>
    </ul>
</div>
<div class="dashboard-container"></div>
    <h1>Welcome Parent</h1>
    <p>Track and support your child’s early learning milestones with ease and care.</p>
    <button class="discover-btn" onclick="document.getElementById('progress').scrollIntoView({ behavior: 'smooth' });">
        Go to Progress
    </button>

    <section class="features d-flex justify-content-around mt-5">
        <div class="feature-item text-center">
            <span class="material-icons">favorite</span>
            <h3>Care</h3>
            <p>Monitor your child’s well-being and milestones.</p>
        </div>
        <div class="feature-item text-center">
            <span class="material-icons">school</span>
            <h3>Learning</h3>
            <p>View learning activities and achievements.</p>
        </div>
        <div class="feature-item text-center">
            <span class="material-icons">chat</span>
            <h3>Messages</h3>
            <p>Stay connected with teachers and staff.</p>
        </div>
    </section>

    <section id="children" class="mt-5">
        <h2>Your Children</h2>
        <% if (childrenList != null && !childrenList.isEmpty()) { %>
            <div class="table-container">
                <table>
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
    </section>

    <section id="progress" style="margin-top: 40px;">
        <h2>Progress Overview</h2>
        <% if (childrenList != null && !childrenList.isEmpty()) { 
            DocumentSnapshot firstChild = childrenList.get(0); %>

            <label for="studentSelect">Select Child:</label>
            <select id="studentSelect" class="form-select" required>
                <option value="">-- Select Child --</option>
                <% for (DocumentSnapshot c : childrenList) { %>  <!-- ✅ Renamed to "c" -->
                    <option value="<%= c.getId() %>"><%= c.getString("fullName") %></option>
                <% } %>
            </select>
        <% } else { %>
            <p style="color: red;">No child found. Please add a child first.</p>
        <% } %>

        <label for="datePicker">Select Date:</label>
        <input type="date" id="datePicker" name="datePicker" required>
        <button class="discover-btn" style="margin-left: 10px;" onclick="loadChartData();">Load Progress</button>
        <div id="chartsContainer" class="mt-4"></div>
    </section>

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
    const studentId = document.getElementById('studentSelect').value;

    if (!studentId || !date) {
        alert("Please select both a child and a date.");
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

                const activityName = activity.activityName ? activity.activityName : 'Unnamed Activity';
                console.log("✅ Activity name about to be displayed:", activityName);
                // === New activity section container ===
                const activityBlock = document.createElement('div');
                activityBlock.style.margin = "40px 0";
                activityBlock.style.padding = "20px";
                activityBlock.style.border = "1px solid #ccc";
                activityBlock.style.borderRadius = "12px";
                activityBlock.style.backgroundColor = "#f9f9f9";
                activityBlock.style.boxShadow = "0 3px 6px rgba(0,0,0,0.05)";

                // Title
                const activityTitle = document.createElement('h4');
                activityTitle.textContent = "Activity: " + activityName;
                activityTitle.style.marginBottom = "20px";
                activityTitle.style.color = "#333";
                activityBlock.appendChild(activityTitle);

                if (literacyLabels.length > 0) {
                    const literacyCanvas = document.createElement('canvas');
                    literacyCanvas.id = `literacyChart_${index}`; // ✅ Unique ID
                    activityBlock.appendChild(literacyCanvas);
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
                    physicalCanvas.id = `physicalChart_${index}`; // ✅ Unique ID
                    activityBlock.appendChild(physicalCanvas);
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
                container.appendChild(activityBlock); // ✅ Add the entire section
            });

            if (Object.keys(pieData).length > 0) {
                const pieContainer = document.createElement('div');
                pieContainer.style.marginTop = "50px";
                pieContainer.style.padding = "20px";
                pieContainer.style.border = "1px solid #ccc";
                pieContainer.style.borderRadius = "12px";
                pieContainer.style.backgroundColor = "#f9f9f9";
                pieContainer.style.boxShadow = "0 3px 6px rgba(0,0,0,0.05)";

                const pieTitle = document.createElement('h3');
                pieTitle.textContent = "Time Duration Per Activity";
                pieTitle.style.marginBottom = "20px";
                pieContainer.appendChild(pieTitle);

                const pieCanvas = document.createElement('canvas');
                pieCanvas.id = "activityTimePieChart";
                pieCanvas.width = 300; // ✅ Smaller
                pieCanvas.height = 300; // ✅ Smaller
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
