package com.example.util.servlet;

import com.google.api.core.ApiFuture;
import com.google.cloud.Timestamp;
import com.google.cloud.firestore.*;
import com.google.firebase.cloud.FirestoreClient;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.*;
import java.util.concurrent.ExecutionException;

import org.json.JSONArray;
import org.json.JSONObject;

@WebServlet("/chartData")
public class chartDataServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String studentId = request.getParameter("studentId");
        String selectedDate = request.getParameter("date");

        if (studentId == null || selectedDate == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Missing studentId or date");
            return;
        }

        Firestore db = FirestoreClient.getFirestore();
        List<JSONObject> activityList = new ArrayList<>();
        Map<String, Double> pieDataMap = new LinkedHashMap<>();

        try {
            CollectionReference assessments = db.collection("ActivityAssessment");

            ApiFuture<QuerySnapshot> future = assessments
                    .whereEqualTo("studentId", studentId)
                    .get();

            List<QueryDocumentSnapshot> documents = future.get().getDocuments();

            for (DocumentSnapshot doc : documents) {
                Timestamp timestamp = doc.getTimestamp("timestamp");
                if (timestamp != null) {
                    String activityDate = new java.text.SimpleDateFormat("yyyy-MM-dd").format(timestamp.toDate());
                    if (!selectedDate.equals(activityDate)) continue;
                }

                String activityId = doc.getString("activityId");
                String activityName = "Unnamed Activity";
                if (activityId != null) {
                    DocumentSnapshot activityDoc = db.collection("dailyActivities").document(activityId).get().get();
                    activityName = activityDoc.getString("name");
                }

                System.out.println("activityId in document: " + activityId);
                System.out.println("Activity Name Found bar: " + activityName);

                JSONObject activityJson = new JSONObject();
                activityJson.put("activityId", activityId);
                activityJson.put("activityName", activityName);

                JSONObject literacyJson = new JSONObject();
                JSONObject physicalJson = new JSONObject();

                Map<String, Object> achievement = (Map<String, Object>) doc.get("achievement");
                if (achievement != null) {
                    Map<String, Object> literacy = (Map<String, Object>) achievement.get("literacy");
                    if (literacy != null) {
                        for (String key : literacy.keySet()) {
                            literacyJson.put(key, Integer.parseInt(literacy.get(key).toString()));
                        }
                    }

                    Map<String, Object> physical = (Map<String, Object>) achievement.get("physical");
                    if (physical != null) {
                        for (String key : physical.keySet()) {
                            physicalJson.put(key, Integer.parseInt(physical.get(key).toString()));
                        }
                    }

                    Number timeToComplete = (Number) achievement.get("timeToComplete");
                    if (activityName != null && timeToComplete != null) {
                        pieDataMap.put(
                            activityName,
                            pieDataMap.getOrDefault(activityName, 0.0) + timeToComplete.doubleValue()
                        );
                    }
                }

                activityJson.put("literacy", literacyJson);
                activityJson.put("physical", physicalJson);
                activityList.add(activityJson);
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("Error retrieving chart data");
            return;
        }

        JSONObject resultJson = new JSONObject();
        resultJson.put("barChart", activityList);
        resultJson.put("pieChart", new JSONObject(pieDataMap));

        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        out.print(resultJson.toString());
        out.flush();
    }
}
