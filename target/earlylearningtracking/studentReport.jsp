<%@ page import="java.util.*, org.json.JSONArray, org.json.JSONObject" %>
<%
  String teacherName = (String) session.getAttribute("username");
  List<Map<String, Object>> reportData = (List<Map<String, Object>>) request.getAttribute("reportData");
%>
<html>
<head>
  <title>Student Report</title>
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
  <h1>Student Report</h1>

  <form method="get" action="studentReport">
    <label>Student:
      <select name="studentId" required>
        <option value="">Choose</option>
        <%
          List<Map<String,String>> studentList = (List<Map<String,String>>) request.getAttribute("studentList");
          String selectedId = request.getParameter("studentId");
          for (Map<String,String> s : studentList) {
        %>
        <option value="<%= s.get("id") %>" <%= s.get("id").equals(selectedId) ? "selected" : "" %>><%= s.get("name") %></option>
        <% } %>
      </select>
    </label>
    <label>Start: <input type="date" name="startDate" required value="<%= request.getParameter("startDate") != null ? request.getParameter("startDate") : "" %>"></label>
    <label>End: <input type="date" name="endDate" required value="<%= request.getParameter("endDate") != null ? request.getParameter("endDate") : "" %>"></label>
    <button type="submit">Generate</button>
  </form>

<% if (request.getAttribute("fullName") != null) { %>
  <h2>Profile</h2>
  Name: <%= request.getAttribute("fullName") %><br>
  DOB: <%= request.getAttribute("dob") %><br>
  Gender: <%= request.getAttribute("gender") %><br>
  Age: <%= request.getAttribute("age") %> months<br>
  Teacher: <%= teacherName %><br>

  <h2>Charts</h2>
  <% int i = 0;
     for (Map<String,Object> one : reportData) {
         Map<String,Double> lit = (Map<String,Double>) one.get("literacyAvg");
         Map<String,Double> phy = (Map<String,Double>) one.get("physicalAvg");
  %>
    <h3><%= one.get("activityName") %></h3>
    const litLabels = JSON.parse('<%= new JSONArray(lit.keySet()) %>');
    const litValues = JSON.parse('<%= new JSONArray(lit.values()) %>');

    const phyLabels = JSON.parse('<%= new JSONArray(phy.keySet()) %>');
    const phyValues = JSON.parse('<%= new JSONArray(phy.values()) %>');
    <script>
      new Chart(document.getElementById('lit<%=i%>').getContext('2d'), {
        type: 'line',
        data: {
          labels: litLabels,
          datasets: [{ label: 'Literacy', data: litValues }]
        }
      });
      new Chart(document.getElementById('phy<%=i%>').getContext('2d'), {
        type: 'line',
        data: {
          labels: phyLabels,
          datasets: [{ label: 'Physical', data: phyValues }]
        }
      });
    </script>
  <% i++; } %>

<% } %>

</body>
</html>
