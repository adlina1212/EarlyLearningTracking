package com.example.util.servlet;

import com.google.cloud.firestore.*;
import com.google.firebase.cloud.FirestoreClient;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;
import java.util.concurrent.ExecutionException;

@WebServlet("/parentDashboard")
public class parentDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String parentId = (session != null) ? (String) session.getAttribute("parentId") : null;

        if (parentId == null || parentId.isEmpty()) {
            response.sendRedirect("login.html");
            return;
        }

        Firestore db = FirestoreClient.getFirestore();

        try {
            // Step 1: Fetch parent document
            DocumentReference parentRef = db.collection("user").document(parentId);
            DocumentSnapshot parentDoc = parentRef.get().get();

            if (!parentDoc.exists()) {
                response.sendRedirect("error.html");
                return;
            }

            request.setAttribute("parentDoc", parentDoc);

            // Step 2: Get list of studentIds from parent document
            List<String> studentIds = (List<String>) parentDoc.get("studentIds");

            List<DocumentSnapshot> childrenList = new java.util.ArrayList<>();

            if (studentIds != null && !studentIds.isEmpty()) {
                // Step 3: Fetch each student document
                for (String studentId : studentIds) {
                    DocumentSnapshot studentDoc = db.collection("student").document(studentId).get().get();
                    if (studentDoc.exists()) {
                        childrenList.add(studentDoc);  // ✅ Corrected
                    }
                }
            }

            // Step 4: Pass data to JSP
            System.out.println("Total children found: " + childrenList.size());
            for (DocumentSnapshot childDoc : childrenList) {
                System.out.println("Student ID: " + childDoc.getId() + ", Name: " + childDoc.getString("fullName"));
            }

            request.setAttribute("childrenList", childrenList);
            request.getRequestDispatcher("parentDashboard.jsp").forward(request, response);

        } catch (InterruptedException | ExecutionException e) {
            e.printStackTrace();
            response.sendRedirect("error.html");
        }
    }
}
