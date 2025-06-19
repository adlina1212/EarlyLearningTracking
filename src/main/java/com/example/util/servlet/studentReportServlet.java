package com.example.util.servlet;

import com.google.api.core.ApiFuture;
import com.google.cloud.Timestamp;
import com.google.cloud.firestore.*;
import com.google.firebase.cloud.FirestoreClient;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.concurrent.ExecutionException;

@WebServlet("/studentReport")
public class studentReportServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String teacherName = session != null ? (String) session.getAttribute("username") : "Unknown";

        Firestore db = FirestoreClient.getFirestore();

        String studentId = request.getParameter("studentId");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");

        List<Map<String, String>> studentList = new ArrayList<>();
        try {
            for (DocumentSnapshot doc : db.collection("student").get().get().getDocuments()) {
                Map<String, String> s = new HashMap<>();
                s.put("id", doc.getId());
                s.put("name", doc.getString("fullName"));
                studentList.add(s);
            }
            request.setAttribute("studentList", studentList);

            if (studentId == null || studentId.isEmpty()) {
                request.getRequestDispatcher("studentReport.jsp").forward(request, response);
                return;
            }

            DocumentSnapshot studentDoc = db.collection("student").document(studentId).get().get();
            if (!studentDoc.exists()) {
                response.sendError(404, "Student not found");
                return;
            }

            String fullName = studentDoc.getString("fullName");
            String dob = studentDoc.getString("dob");
            String gender = studentDoc.getString("gender");
            int age = studentDoc.getLong("age") != null ? studentDoc.getLong("age").intValue() : 0;

            Date rangeStart = null, rangeEnd = null;
            try {
                if (startDate != null && !startDate.isEmpty())
                    rangeStart = new SimpleDateFormat("yyyy-MM-dd").parse(startDate);
                if (endDate != null && !endDate.isEmpty())
                    rangeEnd = new SimpleDateFormat("yyyy-MM-dd").parse(endDate);
            } catch (Exception e) {
                e.printStackTrace();
                response.sendError(400, "Invalid date");
                return;
            }

            List<QueryDocumentSnapshot> docs = db.collection("ActivityAssessment")
                .whereEqualTo("studentId", studentId).get().get().getDocuments();

            // Group by activityId
            Map<String, List<QueryDocumentSnapshot>> grouped = new HashMap<>();
            for (QueryDocumentSnapshot doc : docs) {
                Timestamp ts = doc.getTimestamp("timestamp");
                if (ts == null) continue;
                Date tsDate = ts.toDate();
                boolean inRange = true;
                if (rangeStart != null && tsDate.before(rangeStart)) inRange = false;
                if (rangeEnd != null && tsDate.after(rangeEnd)) inRange = false;
                if (!inRange) continue;

                String aid = doc.getString("activityId");
                grouped.computeIfAbsent(aid, k -> new ArrayList<>()).add(doc);
            }

            // Build report data
            List<Map<String, Object>> reportData = new ArrayList<>();
            for (String aid : grouped.keySet()) {
                List<QueryDocumentSnapshot> list = grouped.get(aid);
                String activityName = list.get(0).getString("activityName");

                Map<String, List<Integer>> literacy = new HashMap<>();
                Map<String, List<Integer>> physical = new HashMap<>();
                for (QueryDocumentSnapshot doc : list) {
                    Map<String, Object> ach = (Map<String, Object>) doc.get("achievement");
                    if (ach != null) {
                        Map<String, Object> lit = (Map<String, Object>) ach.get("literacy");
                        if (lit != null) {
                            for (String k : lit.keySet()) {
                                literacy.computeIfAbsent(k, x -> new ArrayList<>())
                                        .add(Integer.parseInt(lit.get(k).toString()));
                            }
                        }
                        Map<String, Object> phy = (Map<String, Object>) ach.get("physical");
                        if (phy != null) {
                            for (String k : phy.keySet()) {
                                physical.computeIfAbsent(k, x -> new ArrayList<>())
                                        .add(Integer.parseInt(phy.get(k).toString()));
                            }
                        }
                    }
                }
                Map<String, Double> literacyAvg = new LinkedHashMap<>();
                literacy.forEach((k, v) -> literacyAvg.put(k, v.stream().mapToInt(i -> i).average().orElse(0)));
                Map<String, Double> physicalAvg = new LinkedHashMap<>();
                physical.forEach((k, v) -> physicalAvg.put(k, v.stream().mapToInt(i -> i).average().orElse(0)));

                Map<String, Object> one = new HashMap<>();
                one.put("activityName", activityName);
                one.put("literacyAvg", literacyAvg);
                one.put("physicalAvg", physicalAvg);
                reportData.add(one);
            }

            request.setAttribute("fullName", fullName);
            request.setAttribute("dob", dob);
            request.setAttribute("gender", gender);
            request.setAttribute("age", age);
            request.setAttribute("teacherName", teacherName);
            request.setAttribute("reportData", reportData);

            request.getRequestDispatcher("studentReport.jsp").forward(request, response);

        } catch (InterruptedException | ExecutionException e) {
            e.printStackTrace();
            response.sendError(500, "Server error");
        }
    }
}
