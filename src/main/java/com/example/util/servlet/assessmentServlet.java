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
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.concurrent.ExecutionException;

@WebServlet("/assessment")
public class assessmentServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect("login.html");
            return;
        }

        Firestore db = FirestoreClient.getFirestore();

        try {
            // Step 1: Fetch all students
            ApiFuture<QuerySnapshot> studentFuture = db.collection("student").get();
            List<QueryDocumentSnapshot> studentDocs = studentFuture.get().getDocuments();

            List<Map<String, Object>> studentList = new ArrayList<>();

            // Step 2: Format today's date (used as document ID)
            String date = new SimpleDateFormat("yyyy-MM-dd").format(new Date());

            // Step 3: Read attendance map for today
            DocumentSnapshot attendanceDoc = db.collection("attendance").document(date).get().get();
            Map<String, Object> attendanceMap = new HashMap<>();

            if (attendanceDoc.exists() && attendanceDoc.contains("attendance")) {
                attendanceMap = (Map<String, Object>) attendanceDoc.get("attendance");
            }

            for (QueryDocumentSnapshot studentDoc : studentDocs) {
                String studentId = studentDoc.getId();
                String fullname = studentDoc.getString("fullName");

                // Default status
                String status = "no";

                if (attendanceMap.containsKey(studentId)) {
                    Boolean present = (Boolean) attendanceMap.get(studentId);
                    if (present != null && present) {
                        status = "yes";
                    }
                }

                Map<String, Object> studentInfo = new HashMap<>();
                studentInfo.put("id", studentId);
                studentInfo.put("name", fullname);
                studentInfo.put("attendance", status);
                studentList.add(studentInfo);
            }

            // Step 4: Fetch activities from 'dailyActivities' collection
            List<Map<String, Object>> activityList = new ArrayList<>();

            ApiFuture<QuerySnapshot> activityFuture = db.collection("dailyActivities").get();
            List<QueryDocumentSnapshot> activityDocs = activityFuture.get().getDocuments();

            for (QueryDocumentSnapshot doc : activityDocs) {
                Map<String, Object> activityData = new HashMap<>();
                activityData.put("id", doc.getId());
                activityData.put("name", doc.getString("name"));
                activityData.put("description", doc.getString("description"));
                activityData.put("date", doc.getString("date"));
                activityList.add(activityData);
            }

            // Step 5: Set attributes and forward to JSP
            request.setAttribute("students", studentList);
            request.setAttribute("activities", activityList);
            request.getRequestDispatcher("assessment.jsp").forward(request, response);

        } catch (InterruptedException | ExecutionException e) {
            e.printStackTrace();
            response.sendRedirect("error.html");
        }
    }
}