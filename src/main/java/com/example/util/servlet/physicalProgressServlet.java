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
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;

@WebServlet("/physicalProgress")
public class physicalProgressServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null) {
            System.out.println("❌ No session found");
            response.sendRedirect("error.html");
            return;
        }

        String studentId = (String) session.getAttribute("studentId");
        String fullName = (String) session.getAttribute("fullName"); // optional, can be fetched again from Firestore
        String activityId = (String) session.getAttribute("activityId");

        System.out.println("Physical studentId: " + studentId);

        if (studentId == null || studentId.trim().isEmpty()) {
            // If no ID provided, redirect or show error
            response.sendRedirect("error.html");
            return;
        }
        
        Firestore db = FirestoreClient.getFirestore();

        try {
            // Fetch the student document
            DocumentReference studentRef = db.collection("student").document(studentId);
            ApiFuture<DocumentSnapshot> future = studentRef.get();
            DocumentSnapshot studentDoc = future.get();

            if (studentDoc.exists()) {
                Map<String, Object> studentData = studentDoc.getData();
                Long ageLong = studentDoc.getLong("age");
                Integer age = (ageLong != null) ? ageLong.intValue() : 0;

                // Determine age range
                String ageRange = "";
                if (age <= 6) {
                    ageRange = "0-6months";
                } else if (age <= 12) {
                    ageRange = "6-12months";
                } /*else if (age <= 24) {
                    ageRange = "1-2years";
                } else if (age <= 36) {
                    ageRange = "2-3years";
                } */else {
                    // If age is above 3 years, default to 2-3years criteria
                    ageRange = "2-3years";
                }

                // Fetch psychomotor list based on age range
                DocumentReference criteriaRef = db.collection("criteria").document(ageRange);
                ApiFuture<DocumentSnapshot> criteriaFuture = criteriaRef.get();
                DocumentSnapshot criteriaDoc = criteriaFuture.get();

                List<String> psychomotorList = null;
                if (criteriaDoc.exists()) {
                    psychomotorList = (List<String>) criteriaDoc.get("psychomotorList");
                }

                // Set attributes for JSP
                request.setAttribute("student", studentData);
                request.setAttribute("studentId", studentId);
                request.setAttribute("activityId", activityId);
                request.setAttribute("fullName", fullName);
                request.setAttribute("age", age);
                request.setAttribute("psychomotorList", psychomotorList);

                // Forward to JSP
                request.getRequestDispatcher("physicalProgress.jsp").forward(request, response);
            } else {
                response.sendRedirect("error.html");
            }
        } catch (InterruptedException | ExecutionException e) {
            e.printStackTrace();
            response.sendRedirect("error.html");
        }
    }
}
