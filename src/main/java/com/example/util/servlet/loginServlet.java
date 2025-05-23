package com.example.util.servlet;

import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.Query;
import com.google.cloud.firestore.QuerySnapshot;
import com.google.cloud.firestore.DocumentSnapshot;
import com.google.firebase.cloud.FirestoreClient;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.concurrent.ExecutionException;
import com.example.util.FirebaseInitializer;

@WebServlet("/earlylearningtracking/login")
public class loginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        if (username == null || password == null || username.isEmpty() || password.isEmpty()) {
            response.sendRedirect("login.html?error=Please+enter+both+username+and+password");
            return;
        }

        try {
            FirebaseInitializer.initialize();  // Make sure Firebase is initialized
            Firestore db = FirestoreClient.getFirestore();

            // Query Firestore for user with matching username
            Query query = db.collection("user").whereEqualTo("username", username);
            QuerySnapshot querySnapshot = query.get().get();

            if (querySnapshot.isEmpty()) {
                response.sendRedirect("login.html?error=Invalid+username+or+password");
                return;
            }

            DocumentSnapshot userDoc = querySnapshot.getDocuments().get(0);
            String storedPassword = userDoc.getString("password");

            if (storedPassword == null || !password.equals(storedPassword)) {
                response.sendRedirect("login.html?error=Invalid+username+or+password");
                return;
            }

            // Fetch the role
            String role = userDoc.getString("role");
            if (role == null) {
                response.sendRedirect("login.html?error=Account+role+not+defined");
                return;
            }

            // Create session and store user info
            HttpSession session = request.getSession(true);
            session.setAttribute("userId", userDoc.getId());
            session.setAttribute("username", username);
            session.setAttribute("role", role);

            // Redirect based on role
            if (role.equalsIgnoreCase("teacher")) {
                response.sendRedirect("teacherDashboard");
            } else if (role.equalsIgnoreCase("parent")) {
                session.setAttribute("parentId", userDoc.getId());
                response.sendRedirect("parentDashboard");
            } else {
                response.sendRedirect("login.html?error=Unauthorized+role");
            }

        } catch (InterruptedException | ExecutionException e) {
            e.printStackTrace(); // Log the error for server logs
            response.sendRedirect("login.html?error=Authentication+failed");
        }
    }
}
