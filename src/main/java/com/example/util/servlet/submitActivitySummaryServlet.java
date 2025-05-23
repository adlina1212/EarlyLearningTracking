package com.example.util.servlet;

import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.DocumentSnapshot;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.WriteResult;
import com.google.firebase.cloud.FirestoreClient;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutionException;

@WebServlet("/submitActivitySummary")
public class submitActivitySummaryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String studentId = request.getParameter("studentId");
        String activityId = request.getParameter("activityId");

        System.out.println("activity summary studentId = " + studentId);
        System.out.println("activity summary activityId = " + activityId);


        Firestore db = FirestoreClient.getFirestore();

        try {
        // Fetch student document
        DocumentSnapshot studentDoc = db.collection("student").document(studentId).get().get();
        if (studentDoc.exists()) {
            request.setAttribute("studentName", studentDoc.getString("fullName"));
        }

        // Fetch activity document
        // Fetch activity document
        DocumentSnapshot activityDoc = db.collection("dailyActivities").document(activityId).get().get();
        if (activityDoc.exists()) {
            String name = activityDoc.getString("name");
            String description = activityDoc.getString("description");
            String date = activityDoc.getString("date");

            System.out.println("✅ Activity Name: " + name);
            System.out.println("✅ Description: " + description);
            System.out.println("✅ Date: " + date);

            request.setAttribute("activityName", name);
            request.setAttribute("activityDescription", description);
            request.setAttribute("activityDate", date);
        } else {
            System.out.println("❌ Activity document not found for ID: " + activityId);
        }

        request.getRequestDispatcher("activitySummary.jsp").forward(request, response);

    } catch (InterruptedException | ExecutionException e) {
        e.printStackTrace();
        response.sendRedirect("error.html");
    }
}

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String studentId = request.getParameter("studentId");
        String activityId = request.getParameter("activityId");
        String timeToComplete = request.getParameter("timeToComplete");
        String teacherComment = request.getParameter("teacherComment");

        Firestore db = FirestoreClient.getFirestore();

        Map<String, Object> summaryData = new HashMap<>();
        summaryData.put("studentId", studentId);
        summaryData.put("activityId", activityId);
        summaryData.put("timeToComplete", timeToComplete);
        summaryData.put("teacherComment", teacherComment);

        try {
            ApiFuture<WriteResult> future = db.collection("ActivityAssessment")
                    .document(studentId + "_" + activityId)
                    .set(summaryData);
            future.get();
            response.sendRedirect("assessment");  // Redirect back to assessment page
        } catch (InterruptedException | ExecutionException e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp");
        }
    }
}
