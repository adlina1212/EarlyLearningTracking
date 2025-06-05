package com.example.util.servlet;

import com.example.util.FirebaseInitializer;
import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.WriteResult;
import com.google.firebase.FirebaseApp;
import com.google.firebase.cloud.FirestoreClient;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/registerParent")
public class registerParentServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Get form data
        String parentName = request.getParameter("parentName");
        String parentIC = request.getParameter("parentIC");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String occupation = request.getParameter("occupation");
        String address = request.getParameter("address");
        String postcode = request.getParameter("postcode");
        String city = request.getParameter("city");
        String state = request.getParameter("state");
        String password = request.getParameter("password");

        if (parentName == null || email == null || phone == null || password == null) {
            response.sendRedirect("error.html");
            return;
        }

        String parentId = parentIC.trim();
        String username = parentIC.trim();

        // Prepare data to save
        Map<String, Object> parentData = new HashMap<>();
        parentData.put("parentId", parentId);
        parentData.put("parentName", parentName);
        parentData.put("parentIC", parentIC);
        parentData.put("email", email);
        parentData.put("phone", phone);
        parentData.put("occupation", occupation);
        parentData.put("address", address);
        parentData.put("username", username);
        parentData.put("password", password);
        parentData.put("address", address);
        parentData.put("postcode", postcode);
        parentData.put("city", city);
        parentData.put("state", state);
        parentData.put("role", "parent");

        try {
            FirebaseInitializer.initialize();
            // Save to Firestore
            Firestore db = FirestoreClient.getFirestore();
            ApiFuture<WriteResult> future = db.collection("user").document(parentId).set(parentData);
            future.get(); // Wait for write to complete

            // ✅ Store parentId in session
            HttpSession session = request.getSession();
            session.setAttribute("parentId", parentId);

            // Redirect to login or dashboard
            response.sendRedirect("registerChild.jsp" ); // or "registerChild.jsp?parentId=" + parentId;
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("error.html");
        }
    }
}
