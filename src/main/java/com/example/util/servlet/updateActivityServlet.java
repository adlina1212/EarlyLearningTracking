package com.example.util.servlet;

import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.DocumentReference;
import com.google.firebase.cloud.FirestoreClient;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/updateActivity")
public class updateActivityServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String id = request.getParameter("id");
        String name = request.getParameter("name");
        String description = request.getParameter("description");
        String date = request.getParameter("date");
        String focus = request.getParameter("focus");

        try {
            Firestore db = FirestoreClient.getFirestore();
            DocumentReference docRef = db.collection("activities").document(id);

            docRef.update(
                "name", name,
                "description", description,
                "date", date,
                "focus", focus
            );

            // Redirect back to assessment page
            response.sendRedirect("assessment.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Failed to update activity.");
        }
    }
}
