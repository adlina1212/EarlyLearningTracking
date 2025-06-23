<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, org.json.JSONArray, org.json.JSONObject" %>
<%
  String teacherName = (String) session.getAttribute("username");
  
%>
<!DOCTYPE html>
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
  <h2>Profile</h2>
  Name: <%= request.getAttribute("fullName") %><br>
  DOB: <%= request.getAttribute("dob") %><br>
  Gender: <%= request.getAttribute("gender") %><br>
  Age: <%= request.getAttribute("age") %> months<br>
  Teacher: <%= teacherName %><br>

  <h2>Charts</h2>
  <%
// Before the loop
List<Map<String,Object>> reportData = (List<Map<String,Object>>) request.getAttribute("reportData");
int i = 0;
for (Map<String,Object> one : reportData) {
    String activityName = (String) one.get("activityName");
    Map<String,Double> lit = (Map<String,Double>) one.get("literacyAvg");
    Map<String,Double> phy = (Map<String,Double>) one.get("physicalAvg");

    String litLabels = new JSONArray(lit.keySet()).toString();
    String litValues = new JSONArray(lit.values()).toString();
    String phyLabels = new JSONArray(phy.keySet()).toString();
    String phyValues = new JSONArray(phy.values()).toString();
%>

<h3><%= activityName %></h3>
<canvas id="lit<%=i%>"></canvas>
<canvas id="phy<%=i%>"></canvas>
<script>
  const litLabels<%=i%> = <%= litLabels %>;  // NO JSON.parse — it's already valid JS array literal
  const litValues<%=i%> = <%= litValues %>;
  const phyLabels<%=i%> = <%= phyLabels %>;
  const phyValues<%=i%> = <%= phyValues %>;

  new Chart(document.getElementById('lit<%=i%>').getContext('2d'), {
    type: 'line',
    data: {
      labels: litLabels<%=i%>,
      datasets: [{
        label: 'Literacy',
        data: litValues<%=i%>,
        borderColor: 'blue'
      }]
    }
  });

  new Chart(document.getElementById('phy<%=i%>').getContext('2d'), {
    type: 'line',
    data: {
      labels: phyLabels<%=i%>,
      datasets: [{
        label: 'Physical',
        data: phyValues<%=i%>,
        borderColor: 'green'
      }]
    }
  });
</script>

<% i++; } %>
<% } %>

</body>
</html>
