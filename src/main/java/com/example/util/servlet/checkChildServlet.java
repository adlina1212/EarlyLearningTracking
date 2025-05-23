package com.example.util.servlet;

import java.util.List;

import java.io.IOException;
import java.util.concurrent.ExecutionException;

import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.CollectionReference;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QueryDocumentSnapshot;
import com.google.cloud.firestore.QuerySnapshot;
import com.google.cloud.firestore.Query;
import com.google.firebase.cloud.FirestoreClient;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/checkChildRegistration")
public class checkChildServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String parentId = (String) session.getAttribute("parentId");

        if (parentId == null || parentId.isEmpty()) {
            response.sendRedirect("error.html");
            return;
        }

        Firestore db = FirestoreClient.getFirestore();

        try {
            // Query students where parentId == current parentId
            CollectionReference studentRef = db.collection("student");
            Query query = studentRef.whereEqualTo("parentId", parentId);
            ApiFuture<QuerySnapshot> querySnapshot = query.get();

            List<QueryDocumentSnapshot> students = querySnapshot.get().getDocuments();

            if (students.isEmpty()) {
                // No child found, redirect to register child page
                response.sendRedirect("registerChild.jsp");
            } else {
                // Child exists, go to parent dashboard
                response.sendRedirect("parentDashboard.jsp");
            }

        } catch (InterruptedException | ExecutionException e) {
            e.printStackTrace();
            response.sendRedirect("error.html");
        }
    }
}
