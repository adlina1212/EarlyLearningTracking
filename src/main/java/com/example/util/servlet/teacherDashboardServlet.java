package com.example.util.servlet;

import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QueryDocumentSnapshot;
import com.google.cloud.firestore.QuerySnapshot;
import com.google.firebase.cloud.FirestoreClient;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;

@WebServlet("/teacherDashboard")
public class teacherDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Get the current session, do not create a new one if it doesn't exist
        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect("login.html");
            return;
        }

        Firestore db = FirestoreClient.getFirestore();

        try {
            // Fetch students from 'student' collection
            ApiFuture<QuerySnapshot> future = db.collection("student").get();
            List<QueryDocumentSnapshot> documents = future.get().getDocuments();

            List<Map<String, Object>> studentList = new ArrayList<>();

            for (QueryDocumentSnapshot document : documents) {
                String name = document.getString("fullName");
                if (name != null) {
                    Map<String, Object> studentData = new HashMap<>();
                    studentData.put("id",document.getId()); //store document ID for attendance marking
                    studentData.put("name", name);
                    studentList.add(studentData);
                }
            }

            // Pass the list to JSP
            request.setAttribute("student", studentList);

            // Forward to JSP for rendering
            request.getRequestDispatcher("teacherDashboard.jsp").forward(request, response);

        } catch (InterruptedException | ExecutionException e) {
            e.printStackTrace();
            response.sendRedirect("login.html?error=Could not load student list");
        }
    }
}
