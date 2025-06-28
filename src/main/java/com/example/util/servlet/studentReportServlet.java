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
            ApiFuture<QuerySnapshot> allStudentsFuture = db.collection("student").get();
            List<QueryDocumentSnapshot> studentDocs = allStudentsFuture.get().getDocuments();
            for (DocumentSnapshot doc : studentDocs) {
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
            // Get all assessments for this student
            List<QueryDocumentSnapshot> docs = db.collection("ActivityAssessment")
                .whereEqualTo("studentId", studentId).get().get().getDocuments();

            Map<String, List<Integer>> literacy = new HashMap<>();
            Map<String, List<Integer>> physical = new HashMap<>();
            // Group by activityId
            //Map<String, List<QueryDocumentSnapshot>> byActivity = new HashMap<>();
            for (QueryDocumentSnapshot doc : docs) {
                Timestamp ts = doc.getTimestamp("timestamp");
                if (ts == null) continue;
                Date tsDate = ts.toDate();
                boolean inRange = true;
                if (rangeStart != null && tsDate.before(rangeStart)) inRange = false;
                if (rangeEnd != null && tsDate.after(rangeEnd)) inRange = false;
                if (!inRange) continue;

                Map<String, Object> achievement = (Map<String, Object>) doc.get("achievement");
                if (achievement == null) continue;

                Map<String, Object> lit = (Map<String, Object>) achievement.get("literacy");
                if (lit != null) {
                    for (Map.Entry<String, Object> entry : lit.entrySet()) {
                        literacy.computeIfAbsent(entry.getKey(), k -> new ArrayList<>())
                                .add(Integer.parseInt(entry.getValue().toString()));
                    }
                }

                Map<String, Object> phy = (Map<String, Object>) achievement.get("physical");
                if (phy != null) {
                    for (Map.Entry<String, Object> entry : phy.entrySet()) {
                        physical.computeIfAbsent(entry.getKey(), k -> new ArrayList<>())
                                .add(Integer.parseInt(entry.getValue().toString()));
                    }
                }
            }

            Map<String, Double> literacyAvg = new LinkedHashMap<>();
            for (Map.Entry<String, List<Integer>> entry : literacy.entrySet()) {
                double avg = entry.getValue().stream().mapToInt(Integer::intValue).average().orElse(0);
                literacyAvg.put(entry.getKey(), avg);
            }

            Map<String, Double> physicalAvg = new LinkedHashMap<>();
            for (Map.Entry<String, List<Integer>> entry : physical.entrySet()) {
                double avg = entry.getValue().stream().mapToInt(Integer::intValue).average().orElse(0);
                physicalAvg.put(entry.getKey(), avg);
            }

            // Set attributes for JSP
            request.setAttribute("fullName", fullName);
            request.setAttribute("dob", dob);
            request.setAttribute("gender", gender);
            request.setAttribute("age", age);
            request.setAttribute("teacherName", teacherName);
            request.setAttribute("literacyAvg", literacyAvg);
            request.setAttribute("physicalAvg", physicalAvg);

            request.getRequestDispatcher("studentReport.jsp").forward(request, response);

        } catch (InterruptedException | ExecutionException e) {
            e.printStackTrace();
            response.sendError(500, "Server error");
        }
    }
}
