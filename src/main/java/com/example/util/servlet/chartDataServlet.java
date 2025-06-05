package com.example.util.servlet;

import com.google.api.core.ApiFuture;
import com.google.cloud.Timestamp;
import com.google.cloud.firestore.*;
import com.google.firebase.cloud.FirestoreClient;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import com.google.cloud.firestore.QueryDocumentSnapshot;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.*;
import java.util.concurrent.ExecutionException;
import org.json.JSONObject;



@WebServlet("/chartData")
public class chartDataServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        //HttpSession session = request.getSession(false);
        //String studentId = (session != null) ? (String) session.getAttribute("studentId") : null;
        String studentId = request.getParameter("studentId"); // instead of from session
        String selectedDate = request.getParameter("date");

        System.out.println("chartData called with studentId: " + studentId + ", date: " + selectedDate);

        if (studentId == null || selectedDate == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Missing studentId or date");
            return;
        }

        Firestore db = FirestoreClient.getFirestore();
        JSONObject resultJson = new JSONObject();

        try {
            CollectionReference assessments = db.collection("ActivityAssessment");

            ApiFuture<QuerySnapshot> future = assessments
                    .whereEqualTo("studentId", studentId)
                    .get();

            List<QueryDocumentSnapshot> documents = future.get().getDocuments();

            Map<String, Integer> literacyMap = new LinkedHashMap<>();
            Map<String, Integer> physicalMap = new LinkedHashMap<>();

            for (DocumentSnapshot doc : documents) {
                Timestamp timestamp = doc.getTimestamp("timestamp");
                if (timestamp != null) {
                    String activityDate = new java.text.SimpleDateFormat("yyyy-MM-dd").format(timestamp.toDate());
                    if (selectedDate.equals(activityDate)) {
                        Map<String, Object> achievement = (Map<String, Object>) doc.get("achievement");

                        if (achievement != null) {
                            Map<String, Object> literacy = (Map<String, Object>) achievement.get("literacy");
                            if (literacy != null) {
                                for (String key : literacy.keySet()) {
                                    try {
                                        int value = Integer.parseInt(literacy.get(key).toString());
                                        literacyMap.put(key, value);
                                    } catch (NumberFormatException e) {
                                        literacyMap.put(key, 0);
                                    }
                                }
                            }

                            Map<String, Object> physical = (Map<String, Object>) achievement.get("physical");
                            if (physical != null) {
                                for (String key : physical.keySet()) {
                                    try {
                                        int value = Integer.parseInt(physical.get(key).toString());
                                        physicalMap.put(key, value);
                                    } catch (NumberFormatException e) {
                                        physicalMap.put(key, 0);
                                    }
                                }
                            }
                        }
                    }
                }
            }

            resultJson.put("literacy", literacyMap);
            resultJson.put("physical", physicalMap);

            
            System.out.println("selectedDate: " + selectedDate);
            System.out.println("literacyMap: " + literacyMap);
            System.out.println("physicalMap: " + physicalMap);


        } catch (InterruptedException | ExecutionException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("Error retrieving chart data");
            return;
        }

        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        out.print(resultJson.toString());
        out.flush();
    }
}
