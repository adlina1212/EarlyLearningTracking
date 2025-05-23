package com.example.util.servlet;

import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.*;
import com.google.firebase.cloud.FirestoreClient;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.*;
import java.util.concurrent.ExecutionException;

@WebServlet("/registerChildServlet")
@MultipartConfig
public class registerChildServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Firestore db = FirestoreClient.getFirestore();

        // Get session or parent info (if needed)
        HttpSession session = request.getSession();
        String parentId = (String) session.getAttribute("parentId"); // Or retrieve from logged-in user
        if (parentId == null) {
            parentId = "defaultParent"; // fallback
        }

        List<Map<String, Object>> childrenList = new ArrayList<>();

        int index = 0;
        while (true) {
            String name = request.getParameter("childName");
            String dob = request.getParameter("dob");
            String gender = request.getParameter("gender");
            String allergies = request.getParameter("allergies");

            if (name == null || dob == null || gender == null) break; // no more children

            Map<String, Object> childData = new HashMap<>();
            childData.put("fullName", name);
            childData.put("dob", dob);
            childData.put("gender", gender);
            childData.put("allergies", allergies);
            childData.put("createdAt", new Date());

            // Optionally handle file uploads (photo)
            try {
                Part photoPart = request.getPart("photo");
                if (photoPart != null && photoPart.getSize() > 0) {
                    String fileName = photoPart.getSubmittedFileName();
                    // Optional: upload to Firebase Storage and get the URL
                    // For now, just save the filename (not the content)
                    childData.put("photoName", fileName);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }

            // Save each child under `student` collection
            try {
                // Save each child under `student` collection and get the auto-generated ID
                DocumentReference newChildRef = db.collection("student").document();
                ApiFuture<WriteResult> future = newChildRef.set(childData);
                future.get(); // wait for save
    
                // Get the generated studentId
                String studentId = newChildRef.getId();
    
                // Step 2: Update Parent Document with studentId
                DocumentReference parentRef = db.collection("user").document(parentId);
    
                // Use Firestore ArrayUnion to add to array without overwriting existing ones
                ApiFuture<WriteResult> updateFuture = parentRef.update("studentIds", FieldValue.arrayUnion(studentId));
                updateFuture.get(); // wait for update
    
                System.out.println("Student ID " + studentId + " added to parent " + parentId);
    
            } catch (InterruptedException | ExecutionException e) {
                e.printStackTrace();
                response.sendRedirect("error.html");
                return;
            }

            break; // only 1 child supported now — unless using indexed field names (e.g., childName_0, childName_1)
        }

        response.sendRedirect("parentDashboard"); // or wherever you want
    }
}
