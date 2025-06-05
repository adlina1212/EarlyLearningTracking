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
import java.util.*;
import java.util.concurrent.ExecutionException;
import org.json.JSONObject;


@WebServlet("/chartPieData")
public class chartPieDataServlet extends HttpServlet {
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
        Map<String, Double> activityTimeMap = new LinkedHashMap<>();

        try {
            ApiFuture<QuerySnapshot> future = db.collection("ActivityAssessment")
                .whereEqualTo("studentId", studentId)
                .get();

            List<QueryDocumentSnapshot> documents = future.get().getDocuments();

            for (DocumentSnapshot doc : documents) {
                Timestamp ts = doc.getTimestamp("timestamp");
                if (ts != null) {
                    String docDate = new java.text.SimpleDateFormat("yyyy-MM-dd").format(ts.toDate());
                    if (!docDate.equals(selectedDate)) continue;
                }

                String activityName = doc.getString("activityName");
                Number timeToComplete = (Number) doc.get("timeToComplete");

                if (activityName != null && timeToComplete != null) {
                    activityTimeMap.put(
                        activityName,
                        activityTimeMap.getOrDefault(activityName, 0.0) + timeToComplete.doubleValue()
                    );
                }
            }

            JSONObject json = new JSONObject(activityTimeMap);
            response.setContentType("application/json");
            response.getWriter().write(json.toString());

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading pie data");
        }
    }
}

