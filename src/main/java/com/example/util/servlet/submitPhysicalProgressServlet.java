package com.example.util.servlet;

import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.*;
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

@WebServlet("/submitPhysicalProgress")
public class submitPhysicalProgressServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String studentId = request.getParameter("studentId");
        String activityId = request.getParameter("activityId");

        Map<String, Object> assessmentData = new HashMap<>();
        Map<String, Object> achievementData = new HashMap<>();

        // Capture the progress scores (each criteria becomes a field)
        Map<String, Object> progressMap = new HashMap<>();
        Enumeration<String> parameterNames = request.getParameterNames();
        while (parameterNames.hasMoreElements()) {
            String paramName = parameterNames.nextElement();
            if (!paramName.equals("studentId") && !paramName.equals("activityId")
                    && !paramName.equals("teacherComment") && !paramName.equals("timeToComplete")) {
                String progress = request.getParameter(paramName);
                progressMap.put(paramName, progress);
            }
        }

        // Add teacher comment and time to complete
        String teacherComment = request.getParameter("teacherComment");
        String timeToComplete = request.getParameter("timeToComplete");

        achievementData.put("physical", progressMap);
        achievementData.put("teacherComment", teacherComment);
        achievementData.put("timeToComplete", timeToComplete);

        // Main document structure
        assessmentData.put("studentId", studentId);
        assessmentData.put("activityId", activityId);
        assessmentData.put("achievement", achievementData);
        assessmentData.put("timestamp", new Date());

        // Save to Firestore
        try {
            Firestore db = FirestoreClient.getFirestore();
            CollectionReference collection = db.collection("ActivityAssessment");
            DocumentReference docRef = collection.document(); // auto-generated ID
            ApiFuture<WriteResult> future = docRef.set(assessmentData);
            future.get();

            // Redirect logic for multi-step assessment
            HttpSession session = request.getSession();
            if (session == null) {
                System.out.println("❌ No session found");
                response.sendRedirect("error.html");
                return;
            }

            List<String> focusArray = (List<String>) session.getAttribute("focusArray");
            Integer index = (Integer) session.getAttribute("assessmentIndex");

            if (focusArray != null && index != null && index + 1 < focusArray.size()) {
                String nextFocus = focusArray.get(index + 1);
                session.setAttribute("assessmentIndex", index + 1);
                System.out.println("➡️ Redirecting to next assessment page: " + nextFocus + "Progress");
                response.sendRedirect(nextFocus + "Progress?studentId=" + studentId + "&activityId=" + activityId);
            } else {
                System.out.println("✅ Assessment complete. Redirecting to activity summary.");
                response.sendRedirect("submitActivitySummary?studentId=" + studentId + "&activityId=" + activityId);
            }

        } catch (InterruptedException | ExecutionException e) {
            e.printStackTrace();
            response.sendRedirect("error.html");
        }
    }
}
