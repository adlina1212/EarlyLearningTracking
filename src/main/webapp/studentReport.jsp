<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, org.json.JSONArray, org.json.JSONObject" %>
<%
  String teacherName = (String) session.getAttribute("username");
  Map<String, Double> literacyAvg = (Map<String, Double>) request.getAttribute("literacyAvg");
  Map<String, Double> physicalAvg = (Map<String, Double>) request.getAttribute("physicalAvg");
%>
<!DOCTYPE html>
<html>
<head>
  <title>Student Report</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js"></script>
  <link href="https://fonts.googleapis.com/css2?family=Segoe+UI&display=swap" rel="stylesheet">
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
      .profile-box {
        background: #f9f5ff;
        padding: 20px;
        border-radius: 12px;
        margin-bottom: 40px;
      }

      .report-box {
        margin-bottom: 60px;
      }

      .report-box h3 {
        margin-top: 40px;
        color: #6c4aab;
      }

      .report-box canvas {
        margin-top: 20px;
      }

      @media screen and (max-width: 768px) { 
      .top-nav { 
        flex-direction: column; 
        align-items: flex-start; 
        padding: 20px; } 
        .nav-links { 
          flex-direction: column; 
          gap: 10px; 
          margin-top: 10px; 
        } 
      }
  </style>
</head>
<body>
  <!-- Top Navigation -->
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
<div class="dashboard-container" id="reportContent">
  <h1>Student Report</h1>

  <form method="get" action="studentReport">
    <label>Student:
      <select name="studentId" required>
        <option value="">Choose</option>
        <%
          List<Map<String,String>> studentList = (List<Map<String,String>>) request.getAttribute("studentList");
          String selectedId = request.getParameter("studentId");
          if (studentList != null) {
            for (Map<String, String> s : studentList) {
              String id = s.get("id");
              String name = s.get("name");
          %>
          <option value="<%=id%>" <%= id.equals(selectedId) ? "selected" : "" %>><%=name%></option>
          <% } } %>
      </select>
    </label>
    <label>Start: <input type="date" name="startDate" required value="<%= request.getParameter("startDate") != null ? request.getParameter("startDate") : "" %>"></label>
    <label>End: <input type="date" name="endDate" required value="<%= request.getParameter("endDate") != null ? request.getParameter("endDate") : "" %>"></label>
    <button type="submit">Generate</button>
  </form>

  <% if (request.getAttribute("fullName") != null) { %>
  <div class="profile-box">
    <h2>Student Profile</h2>
    <p><strong>Name:</strong> <%= request.getAttribute("fullName") %></p>
    <p><strong>DOB:</strong> <%= request.getAttribute("dob") %></p>
    <p><strong>Gender:</strong> <%= request.getAttribute("gender") %></p>
    <p><strong>Age:</strong> <%= request.getAttribute("age") %> months</p>
    <p><strong>Teacher:</strong> <%= teacherName %></p>
  </div>
  <!-- Literacy Report -->
  <div class="report-box">
      <h3>Literacy Assessment</h3>
      <canvas id="literacyChart" height="100"></canvas>
      <table>
        <tr><th>Criterion</th><th>Average Score</th></tr>
        <% for (Map.Entry<String, Double> entry : literacyAvg.entrySet()) { %>
          <tr><td><%= entry.getKey() %></td><td><%= String.format("%.2f", entry.getValue()) %></td></tr>
        <% } %>
      </table>
    </div>
  <!-- Physical Report -->
  <div class="report-box">
      <h3>Physical Assessment</h3>
      <canvas id="physicalChart" height="100"></canvas>
      <table>
        <tr><th>Criterion</th><th>Average Score</th></tr>
        <% for (Map.Entry<String, Double> entry : physicalAvg.entrySet()) { %>
          <tr><td><%= entry.getKey() %></td><td><%= String.format("%.2f", entry.getValue()) %></td></tr>
        <% } %>
      </table>
    </div>

  <button class="btn-download" onclick="generatePDF()">Download Report as PDF</button>
  <% } %>
</div>

<script>
  const literacyData = <%= new JSONObject(literacyAvg) %>;
  const physicalData = <%= new JSONObject(physicalAvg) %>;

  const drawLineChart = (canvasId, labels, values, label, color) => {
    new Chart(document.getElementById(canvasId).getContext('2d'), {
      type: 'line',
      data: {
        labels: labels,
        datasets: [{
          label: label,
          data: values,
          borderColor: color,
          backgroundColor: color.replace('1)', '0.1)'),
          fill: true,
          tension: 0.3
        }]
      },
      options: {
        responsive: true,
        scales: { y: { beginAtZero: true, min: 0, max: 5 } }
      }
    });
  }

  drawLineChart("literacyChart", Object.keys(literacyData), Object.values(literacyData), "Literacy Avg Score", "rgba(108,99,255,1)");
  drawLineChart("physicalChart", Object.keys(physicalData), Object.values(physicalData), "Physical Avg Score", "rgba(76,175,80,1)");

  async function generatePDF() {
    const { jsPDF } = window.jspdf;
    const doc = new jsPDF('p', 'pt', 'a4');
    const content = document.getElementById('reportContent');

    await html2canvas(content, {
      scale: 2, // better resolution
      useCORS: true, // allow cross-origin images
      scrollY: -window.scrollY // fix partial view issues
    }).then(canvas => {
      const imgData = canvas.toDataURL("image/png");
      const pdfWidth = doc.internal.pageSize.getWidth();
      const pdfHeight = (canvas.height * pdfWidth) / canvas.width;

      // For long pages, we split the image vertically into multiple pages
      let position = 0;
      const pageHeight = doc.internal.pageSize.getHeight();

      while (position < pdfHeight) {
        doc.addImage(imgData, 'PNG', 0, -position, pdfWidth, pdfHeight);
        position += pageHeight;
        if (position < pdfHeight) doc.addPage();
      }

      doc.save("student-report.pdf");
    });
  }
</script>
</body>
</html>
