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

        if (parentId == null) {
            response.sendRedirect("login.html");
            return;
        }

        Firestore db = FirestoreClient.getFirestore();

        try {
            // Fetch parent info
            DocumentSnapshot parentDoc = db.collection("user").document(parentId).get().get();
            request.setAttribute("parentDoc", parentDoc);

            // Fetch children
            QuerySnapshot childDocs = db.collection("student")
                    .whereEqualTo("parentId", parentId)
                    .get()
                    .get();

            List<QueryDocumentSnapshot> childrenList = childDocs.getDocuments();

            request.setAttribute("childrenList", childrenList);
            if (childrenList.isEmpty()) {
                request.setAttribute("noChildren", true);
            }

            // Forward to JSP
            request.getRequestDispatcher("/parentDashboard.jsp").forward(request, response);

        } catch (InterruptedException | ExecutionException e) {
            e.printStackTrace();
            response.sendRedirect("error.html");
        }
    }
}

