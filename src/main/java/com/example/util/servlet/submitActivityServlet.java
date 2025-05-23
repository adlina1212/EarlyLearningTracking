package com.example.util.servlet;

import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.FirestoreOptions;
import com.google.firebase.cloud.FirestoreClient;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/submitActivity")
public class submitActivityServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Retrieve form parameters
        String activityDate = request.getParameter("activityDate");
        String activityName = request.getParameter("activityName");
        String activityDescription = request.getParameter("activityDescription");
        String timeToComplete = request.getParameter("timeToComplete");
        String teacherComment = request.getParameter("teacherComment");

        // Create a map of activity data
        Map<String, Object> activityData = new HashMap<>();
        activityData.put("date", activityDate);
        activityData.put("name", activityName);
        activityData.put("description", activityDescription);
        activityData.put("timeToComplete", timeToComplete);
        activityData.put("teacherComment", teacherComment);

        try {
            // Save to Firestore
            Firestore db = FirestoreClient.getFirestore();
            db.collection("dailyActivities").add(activityData);

            response.sendRedirect("assessment?success=true");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("assessment?error=true");
        }
    }
}
