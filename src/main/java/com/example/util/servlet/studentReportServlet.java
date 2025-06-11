package com.example.util.servlet;

import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.*;
import com.google.firebase.cloud.FirestoreClient;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.json.JSONArray;
import org.json.JSONObject;
import com.google.cloud.Timestamp;

import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.*;

@WebServlet("/generateReportData")
public class studentReportServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String studentId = request.getParameter("studentId");

        if (studentId == null || studentId.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Missing studentId");
            return;
        }

        Firestore db = FirestoreClient.getFirestore();

        try {
            DocumentSnapshot studentDoc = db.collection("student").document(studentId).get().get();

            if (!studentDoc.exists()) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.getWriter().write("Student not found");
                return;
            }

            Map<String, Object> studentProfile = new HashMap<>();
            studentProfile.put("fullName", studentDoc.getString("fullName"));
            studentProfile.put("dob", studentDoc.getString("dob"));
            studentProfile.put("gender", studentDoc.getString("gender"));
            studentProfile.put("photoUrl", studentDoc.getString("photoUrl"));

            CollectionReference assessments = db.collection("ActivityAssessment");
            ApiFuture<QuerySnapshot> future = assessments.whereEqualTo("studentId", studentId).get();
            List<QueryDocumentSnapshot> documents = future.get().getDocuments();

            Map<String, List<Integer>> monthlyProgress = new HashMap<>();
            monthlyProgress.put("Literacy", new ArrayList<>(Collections.nCopies(12, 0)));
            monthlyProgress.put("Physical", new ArrayList<>(Collections.nCopies(12, 0)));
            monthlyProgress.put("Cognitive", new ArrayList<>(Collections.nCopies(12, 0)));

            Map<String, Integer> monthCounts = new HashMap<>();

            for (DocumentSnapshot doc : documents) {
                Timestamp ts = doc.getTimestamp("timestamp");
                if (ts == null) continue;

                Calendar calendar = Calendar.getInstance();
                calendar.setTime(ts.toDate());
                int month = calendar.get(Calendar.MONTH); // 0-based index

                Map<String, Object> achievement = (Map<String, Object>) doc.get("achievement");
                if (achievement == null) continue;

                for (String domain : Arrays.asList("literacy", "physical", "cognitive")) {
                    Map<String, Object> domainData = (Map<String, Object>) achievement.get(domain);
                    if (domainData != null) {
                        int total = 0;
                        for (Object val : domainData.values()) {
                            try {
                                total += Integer.parseInt(val.toString());
                            } catch (NumberFormatException e) {
                                continue;
                            }
                        }
                        List<Integer> domainList = monthlyProgress.get(domain.substring(0, 1).toUpperCase() + domain.substring(1));
                        domainList.set(month, domainList.get(month) + total);
                        monthCounts.put(domain + month, monthCounts.getOrDefault(domain + month, 0) + domainData.size());
                    }
                }
            }

            for (String domain : monthlyProgress.keySet()) {
                List<Integer> progressList = monthlyProgress.get(domain);
                for (int i = 0; i < 12; i++) {
                    String key = domain.toLowerCase() + i;
                    int count = monthCounts.getOrDefault(key, 0);
                    if (count > 0) {
                        progressList.set(i, progressList.get(i) / count);
                    }
                }
            }

            JSONObject json = new JSONObject();
            json.put("profile", studentProfile);
            json.put("progress", monthlyProgress);

            response.setContentType("application/json");
            PrintWriter out = response.getWriter();
            out.print(json.toString());
            out.flush();
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error generating report");
        }
    }
}
