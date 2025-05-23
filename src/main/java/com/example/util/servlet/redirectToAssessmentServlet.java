package com.example.util.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;

import com.google.cloud.firestore.DocumentSnapshot;
import com.google.cloud.firestore.Firestore;
import com.google.firebase.cloud.FirestoreClient;

@WebServlet("/redirectToAssessment")
public class redirectToAssessmentServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String studentId = request.getParameter("studentId");
        String activityId = request.getParameter("activityId");
        String[] focuses = request.getParameterValues("focuses");

        System.out.println("studentId: " + studentId);
        System.out.println("activityId: " + activityId);
        System.out.println("focuses: " + Arrays.toString(focuses));

        if (studentId == null || studentId.trim().isEmpty() ||
            activityId == null || activityId.trim().isEmpty() ||
            focuses == null || focuses.length == 0) {

            System.out.println("🚫 Missing input, redirecting to error.html");
            response.sendRedirect("error.html");
            return;
        }

        // Continue with redirect logic
        HttpSession session = request.getSession(true);
        session.setAttribute("studentId", studentId);
        session.setAttribute("activityId", activityId);
        session.setAttribute("focuses", Arrays.asList(focuses));
        session.setAttribute("assessmentIndex", 0);

        try {
            Firestore db = FirestoreClient.getFirestore();
            DocumentSnapshot doc = db.collection("student").document(studentId).get().get();
            if (doc.exists()) {
                String fullName = doc.getString("fullName");
                session.setAttribute("fullName", fullName);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("error2.html");
            return;
        }

        String firstFocus = focuses[0].trim().toLowerCase();
        System.out.println("Redirecting to: " + firstFocus);


        if ("literacy".equalsIgnoreCase(firstFocus)) {
            response.sendRedirect("literacyProgress");
            System.out.println("Sent redirect to literacyProgress page");

        } 
        if ("physical".equalsIgnoreCase(firstFocus)) {
            response.sendRedirect("physicalProgress");
            System.out.println("Sent redirect to physicalProgress page");
        } else {
            System.out.println("⚠️ Invalid focus value, redirecting to error2.html");
            response.sendRedirect("error2.html");
        }

    }
}
