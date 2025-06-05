package com.example.util.servlet;

import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.DocumentReference;
import com.google.cloud.firestore.DocumentSnapshot;
import com.google.cloud.firestore.Firestore;
import com.google.firebase.cloud.FirestoreClient;
//import com.google.firestore.v1.WriteResult;
import com.google.cloud.firestore.WriteResult;
import com.google.gson.Gson;
import com.google.gson.JsonObject;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.BufferedReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutionException;

@WebServlet("/profile")
public class profileServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect("login");
            return;
        }

        String username = (String) session.getAttribute("username");
        Firestore db = FirestoreClient.getFirestore();

        try {
            DocumentSnapshot userDoc = db.collection("user")
                    .whereEqualTo("username", username)
                    .get()
                    .get()
                    .getDocuments()
                    .get(0);  // Assume username is unique

            String role = userDoc.getString("role");
            request.setAttribute("userId", userDoc.getId());
            session.setAttribute("userId", userDoc.getId());  // Add this
            request.setAttribute("username", userDoc.getString("username"));
            request.setAttribute("fullName", userDoc.getString("fullName"));
            request.setAttribute("role", role);
            request.setAttribute("phone", userDoc.getString("phone"));
            request.setAttribute("email", userDoc.getString("email"));

            if ("parent".equals(role)) {
                request.setAttribute("parentsName", userDoc.getString("parentsName"));
                request.setAttribute("studentPhoto", userDoc.getString("studentPhoto"));
                request.getRequestDispatcher("profileParent.jsp").forward(request, response);
            }
            else{
                request.getRequestDispatcher("profileTeacher.jsp").forward(request, response);
            }
            

        } catch (InterruptedException | ExecutionException | IndexOutOfBoundsException e) {
            e.printStackTrace();
            response.sendRedirect("error.html");
        }
    }
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        /*String userId = request.getParameter("userId");
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");

        Firestore db = FirestoreClient.getFirestore();

        try {
            db.collection("user").document(userId)
                    .update("phone", phone, "email", email);

            response.getWriter().write("success");
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("error");
        }*/
       BufferedReader reader = request.getReader();
       StringBuilder jsonBuilder = new StringBuilder();
       String line;
       while ((line = reader.readLine()) != null) {
           jsonBuilder.append(line);
        }
       String json = jsonBuilder.toString();

       Firestore db = FirestoreClient.getFirestore();

       // Parse JSON
       Gson gson = new Gson();  // Make sure you have Gson in your dependencies
       JsonObject jsonObject = gson.fromJson(json, JsonObject.class);

       String userId = jsonObject.get("userId").getAsString();
       String phone = jsonObject.get("phone").getAsString();
       String email = jsonObject.get("email").getAsString();

       // Firebase logic here: update Firestore
       boolean updateSuccess = false;
       
       try {

        DocumentReference userRef = db.collection("user").document(userId);

        Map<String, Object> updates = new HashMap<>();
        updates.put("phone", phone);
        updates.put("email", email);
        System.out.println("Updating user: " + userId + " | New phone: " + phone + " | New email: " + email);

        ApiFuture<WriteResult> writeResult = userRef.update(updates);
        writeResult.get();  // Wait for the update to complete

        updateSuccess = true;
        } catch (Exception e) {
        e.printStackTrace();  // Log error in Tomcat console
        }

       if (updateSuccess) {
          response.setStatus(HttpServletResponse.SC_OK);
       } else {
           response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
       } 
    }
}
