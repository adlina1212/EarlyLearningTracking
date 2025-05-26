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
        String parentId = (String) session.getAttribute("parentId");
        if (parentId == null) {
            parentId = "defaultParent"; // fallback
        }

        try {
            String[] names = request.getParameterValues("childName[]");
            String[] dobs = request.getParameterValues("dob[]");
            String[] genders = request.getParameterValues("gender[]");
            String[] allergiesArr = request.getParameterValues("allergies[]");

            Collection<Part> parts = request.getParts();
            List<Part> photoParts = new ArrayList<>();
            for (Part part : parts) {
                if ("photo[]".equals(part.getName())) {
                    photoParts.add(part);
                }
            }

            for (int i = 0; i < names.length; i++) {
                String name = names[i];
                String dob = dobs[i];
                String gender = genders[i];
                String allergies = allergiesArr[i];

                Map<String, Object> childData = new HashMap<>();
                childData.put("fullName", name);
                childData.put("dob", dob);
                childData.put("gender", gender);
                childData.put("allergies", allergies);
                childData.put("createdAt", new Date());

                if (i < photoParts.size()) {
                    Part photoPart = photoParts.get(i);
                    if (photoPart != null && photoPart.getSize() > 0) {
                        String fileName = photoPart.getSubmittedFileName();
                        childData.put("photoName", fileName);
                    }
                }

                DocumentReference newChildRef = db.collection("student").document();
                ApiFuture<WriteResult> future = newChildRef.set(childData);
                future.get();

                String studentId = newChildRef.getId();
                DocumentReference parentRef = db.collection("user").document(parentId);
                ApiFuture<WriteResult> updateFuture = parentRef.update("studentIds", FieldValue.arrayUnion(studentId));
                updateFuture.get();

                System.out.println("Student ID " + studentId + " added to parent " + parentId);
            }

            response.sendRedirect("parentDashboard");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("error.html");
        }
    }
}
