package com.example.util.servlet;

import com.google.api.core.ApiFuture;
import com.google.cloud.Timestamp;
import com.google.cloud.firestore.*;
import com.google.firebase.cloud.FirestoreClient;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import org.json.JSONObject;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.concurrent.ExecutionException;

@WebServlet("/lineChartData")
public class lineChartDataServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String studentId = request.getParameter("studentId");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");

        if (studentId == null || studentId.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing studentId");
            return;
        }

        Firestore db = FirestoreClient.getFirestore();

        try {
            Date rangeStart = null, rangeEnd = null;
            try {
                if (startDate != null && !startDate.isEmpty()) {
                    rangeStart = new SimpleDateFormat("yyyy-MM-dd").parse(startDate);
                }
                if (endDate != null && !endDate.isEmpty()) {
                    rangeEnd = new SimpleDateFormat("yyyy-MM-dd").parse(endDate);
                }
            } catch (java.text.ParseException e) {
                e.printStackTrace();
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid date format");
                return;
            }

            CollectionReference assessments = db.collection("ActivityAssessment");
            ApiFuture<QuerySnapshot> future = assessments.whereEqualTo("studentId", studentId).get();
            List<QueryDocumentSnapshot> docs = future.get().getDocuments();

            Map<String, List<Integer>> literacyCriteria = new HashMap<>();
            Map<String, List<Integer>> physicalCriteria = new HashMap<>();

            for (QueryDocumentSnapshot doc : docs) {
                Timestamp ts = doc.getTimestamp("timestamp");
                if (ts == null) continue;
                Date tsDate = ts.toDate();

                if (rangeStart != null && tsDate.before(rangeStart)) continue;
                if (rangeEnd != null && tsDate.after(rangeEnd)) continue;

                Map<String, Object> achievement = (Map<String, Object>) doc.get("achievement");
                if (achievement != null) {
                    Map<String, Object> literacy = (Map<String, Object>) achievement.get("literacy");
                    if (literacy != null) {
                        for (String key : literacy.keySet()) {
                            literacyCriteria.computeIfAbsent(key, k -> new ArrayList<>())
                                    .add(Integer.parseInt(literacy.get(key).toString()));
                        }
                    }

                    Map<String, Object> physical = (Map<String, Object>) achievement.get("physical");
                    if (physical != null) {
                        for (String key : physical.keySet()) {
                            physicalCriteria.computeIfAbsent(key, k -> new ArrayList<>())
                                    .add(Integer.parseInt(physical.get(key).toString()));
                        }
                    }
                }
            }

            Map<String, Double> literacyAvg = new LinkedHashMap<>();
            literacyCriteria.forEach((k, v) -> literacyAvg.put(k, v.stream().mapToInt(i -> i).average().orElse(0)));
            Map<String, Double> physicalAvg = new LinkedHashMap<>();
            physicalCriteria.forEach((k, v) -> physicalAvg.put(k, v.stream().mapToInt(i -> i).average().orElse(0)));

            JSONObject json = new JSONObject();
            json.put("literacyAvg", new JSONObject(literacyAvg));
            json.put("physicalAvg", new JSONObject(physicalAvg));

            response.setContentType("application/json");
            response.getWriter().write(json.toString());

        } catch (InterruptedException | ExecutionException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading chart data");
        }
    }
}
