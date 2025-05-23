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

@WebServlet("/submitLiteracyProgress")
public class submitLiteracyProgressServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String studentId = request.getParameter("studentId");
        String activityId = request.getParameter("activityId");

        // Create the outer document structure
        Map<String, Object> assessmentData = new HashMap<>();
        Map<String, Object> achievementData = new HashMap<>();

        // Collect progress values into a map
        Map<String, Object> progressMap = new HashMap<>();

        Enumeration<String> parameterNames = request.getParameterNames();
        while (parameterNames.hasMoreElements()) {
            String paramName = parameterNames.nextElement();
            if (!paramName.equals("studentId") &&
                !paramName.equals("activityId") &&
                !paramName.equals("teacherComment") &&
                !paramName.equals("timeToComplete")) {
        
            String progress = request.getParameter(paramName);
            progressMap.put(paramName, progress);  // ✅ collect into progressMap
            }   
        }  

        // Put progressMap under "literacy" inside achievement
        achievementData.put("literacy", progressMap);
        achievementData.put("teacherComment", request.getParameter("teacherComment"));
        achievementData.put("timeToComplete", request.getParameter("timeToComplete"));

        // Add everything into the final document
        assessmentData.put("studentId", studentId);
        assessmentData.put("activityId", activityId);
        assessmentData.put("achievement", achievementData);  // ✅ ensure this is here
        assessmentData.put("timestamp", new Date());



        // Save to Firestore
        try {
            Firestore db = FirestoreClient.getFirestore();
            CollectionReference collection = db.collection("ActivityAssessment");
            DocumentReference docRef = collection.document(); // auto-generated ID
            ApiFuture<WriteResult> future = docRef.set(assessmentData);
            future.get();

            // Redirect logic for multi-step assessment
            HttpSession session = request.getSession(false); // Do not create a new session
            if (session == null) {
                System.out.println("❌ No session found");
                response.sendRedirect("error.html");
                return;
            }

            List<String> focusArray = (List<String>) session.getAttribute("focusArray");
            Integer index = (Integer) session.getAttribute("assessmentIndex");

            Enumeration<String> attrs = session.getAttributeNames();
            while (attrs.hasMoreElements()) {
                String attr = attrs.nextElement();
                System.out.println("🧩 " + attr + " = " + session.getAttribute(attr));
            }

            if (focusArray != null && index != null && index + 1 < focusArray.size()) {
                String nextFocus = focusArray.get(index + 1);
                session.setAttribute("assessmentIndex", index + 1);
                System.out.println("➡️ Redirecting to next assessment page: " + nextFocus + "Progress");
                response.sendRedirect(nextFocus + "Progress?studentId=" + studentId + "&activityId=" + activityId);
            } else {
                System.out.println("➡️ Redirecting to: submitActivitySummary?studentId=" + studentId + "&activityId=" + activityId);
                response.sendRedirect("submitActivitySummary?studentId=" + studentId + "&activityId=" + activityId);
            }   


        } catch (InterruptedException | ExecutionException e) {
            e.printStackTrace();
            response.sendRedirect("error.html");
        }
    }
}
