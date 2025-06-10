package com.example.util.servlet;

import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.CollectionReference;
import com.google.cloud.firestore.DocumentReference;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.WriteResult;
import com.google.firebase.cloud.FirestoreClient;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.*;
import java.util.concurrent.ExecutionException;

@WebServlet("/submitProgress")
public class submitProgressServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String studentId = request.getParameter("studentId");
        String activityId = request.getParameter("activityId");

        Map<String, Object> assessmentData = new HashMap<>();
        Map<String, Object> achievementData = new HashMap<>();

        Map<String, Object> literacyMap = new HashMap<>();
        Map<String, Object> physicalMap = new HashMap<>();

        // Parse all parameters and categorize
        Enumeration<String> parameterNames = request.getParameterNames();
        while (parameterNames.hasMoreElements()) {
            String paramName = parameterNames.nextElement();
            if (paramName.startsWith("literacy_")) {
                String progress = request.getParameter(paramName);
                literacyMap.put(paramName, progress);
            } else if (paramName.startsWith("physical_")) {
                String progress = request.getParameter(paramName);
                physicalMap.put(paramName, progress);
            }
        }

        // Add teacher comment and time to complete
        String teacherComment = request.getParameter("teacherComment");
        String timeToCompleteStr = request.getParameter("timeToComplete");
        Number timeToComplete = null;

        try {
            timeToComplete = Double.parseDouble(timeToCompleteStr);  // or Integer.parseInt(...) if only whole numbers
        } catch (NumberFormatException e) {
            timeToComplete = 0;  // fallback or handle error
        }

        // Put data into achievement map
        achievementData.put("literacy", literacyMap);
        achievementData.put("physical", physicalMap);
        achievementData.put("teacherComment", teacherComment);
        achievementData.put("timeToComplete", timeToComplete);

        // Final structure
        assessmentData.put("studentId", studentId);
        assessmentData.put("activityId", activityId);
        assessmentData.put("achievement", achievementData);
        assessmentData.put("timestamp", new Date());

        try {
            Firestore db = FirestoreClient.getFirestore();
            CollectionReference collection = db.collection("ActivityAssessment");
            DocumentReference docRef = collection.document(); // Auto ID
            ApiFuture<WriteResult> future = docRef.set(assessmentData);
            future.get();

            // Redirect to assessment overview or confirmation
            response.sendRedirect("assessment");

        } catch (InterruptedException | ExecutionException e) {
            e.printStackTrace();
            response.sendRedirect("error.html");
        }
    }
}
