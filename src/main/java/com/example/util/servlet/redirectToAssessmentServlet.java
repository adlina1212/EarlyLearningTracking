package com.example.util.servlet;

import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.DocumentReference;
import com.google.cloud.firestore.DocumentSnapshot;
import com.google.cloud.firestore.Firestore;
import com.google.firebase.cloud.FirestoreClient;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Date;
import java.util.List;
import java.time.LocalDate;
import java.time.Period;
import java.time.ZoneId;

@WebServlet("/redirectToAssessment")
public class redirectToAssessmentServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String studentId = request.getParameter("studentId");
        String activityId = request.getParameter("activityId");
        String[] focuses = request.getParameterValues("focuses");
    
        System.out.println("studentId = " + studentId);
        System.out.println("activityId = " + activityId);
        System.out.println("focuses = " + Arrays.toString(focuses));

        if (studentId == null || activityId == null || focuses == null || focuses.length == 0) {
            response.sendRedirect("error.html");
            return;
        }

        try {
            Firestore db = FirestoreClient.getFirestore();

            // Fetch student data
            DocumentSnapshot studentDoc = db.collection("student").document(studentId).get().get();
            String fullName = studentDoc.getString("fullName");
            String dobStr = studentDoc.getString("dob");

            int age = 0;
            if (dobStr != null) {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                Date dob = sdf.parse(dobStr);
                LocalDate birthDate = dob.toInstant().atZone(ZoneId.systemDefault()).toLocalDate();
                LocalDate currentDate = LocalDate.now();
                Period period = Period.between(birthDate, currentDate);
                age = period.getYears() * 12 + period.getMonths();
            }

            // Determine age range for criteria
            String ageRange = (age <= 6) ? "0-6months" : (age <= 12) ? "6-12months" : "2-3years";

            // Fetch criteria data
            //DocumentSnapshot criteriaDoc = db.collection("criteria").document(ageRange).get().get();
            //List<String> literacyList = (List<String>) criteriaDoc.get("literacyList");
            //List<String> physicalList = (List<String>) criteriaDoc.get("physicalList");
            List<String> focusList = Arrays.asList(focuses);

            if (focusList.contains("physical")) {
                DocumentReference criteriaRef = db.collection("criteria").document(ageRange);
                ApiFuture<DocumentSnapshot> criteriaFuture = criteriaRef.get();
                DocumentSnapshot criteriaDoc = criteriaFuture.get();
    
                if (criteriaDoc.exists()) {
                    List<String> psychomotorList = (List<String>) criteriaDoc.get("psychomotorList");
                    request.setAttribute("psychomotorList", psychomotorList);
                }
            }
            if (focusList.contains("literacy")) {
                DocumentReference criteriaRef = db.collection("criteria").document(ageRange);
                ApiFuture<DocumentSnapshot> criteriaFuture = criteriaRef.get();
                DocumentSnapshot criteriaDoc = criteriaFuture.get();
    
                if (criteriaDoc.exists()) {
                    List<String> literacyList = (List<String>) criteriaDoc.get("literacyList");
                    request.setAttribute("literacyList", literacyList);
                }
            }


            // Fetch activity details
            DocumentSnapshot activityDoc = db.collection("dailyActivities").document(activityId).get().get();
            String activityName = activityDoc.getString("name");
            String activityDescription = activityDoc.getString("description");
            String activityDate = activityDoc.getString("date");

            // Set session attributes
            HttpSession session = request.getSession(true);
            session.setAttribute("studentId", studentId);
            session.setAttribute("activityId", activityId);
            session.setAttribute("focusArray", Arrays.asList(focuses));
            session.setAttribute("assessmentIndex", 0);

            // Set request attributes for progress.jsp
            request.setAttribute("studentId", studentId);
            request.setAttribute("fullName", fullName);
            request.setAttribute("age", age);
            request.setAttribute("focuses", focuses);
            request.setAttribute("activityId", activityId);
            request.setAttribute("activityName", activityName);
            request.setAttribute("activityDescription", activityDescription);
            request.setAttribute("activityDate", activityDate);
            request.setAttribute("date", new SimpleDateFormat("yyyy-MM-dd").format(new Date()));

            // Forward to progress.jsp
            request.getRequestDispatcher("progress.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("error.html");
        }
    }
} 
