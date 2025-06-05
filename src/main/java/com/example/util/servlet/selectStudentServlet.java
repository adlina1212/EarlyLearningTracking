package com.example.util.servlet;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.*;

import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.*;
import com.google.firebase.cloud.FirestoreClient;
import com.google.cloud.firestore.QueryDocumentSnapshot;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/selectStudent")
public class selectStudentServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String activityId = request.getParameter("activityId");
        String[] focusArray = request.getParameterValues("focuses");
        String dateAttendance = request.getParameter("dateSelect");
        if (dateAttendance == null) {
            // fallback to today’s date or ask user to input in JSP
            dateAttendance = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
        }


        System.out.println("activityId: " + activityId);
        System.out.println("focusArray: " + Arrays.toString(focusArray));
        System.out.println("date: " + dateAttendance);


        if (activityId == null || focusArray == null || dateAttendance == null) {
            response.sendRedirect("error.html");
            return;
        }

        List<Map<String, Object>> studentList = new ArrayList<>();

        try {
            Firestore db = FirestoreClient.getFirestore();

            // Step 1: Get the attendance map from the document with ID = date
            DocumentSnapshot attendanceDoc = db.collection("attendance").document(dateAttendance).get().get();

            Map<String, Object> attendanceMap = new HashMap<>();
            if (attendanceDoc.exists()) {
                Object raw = attendanceDoc.get("attendance");
                if (raw instanceof Map) {
                    attendanceMap = (Map<String, Object>) raw;
                } else {
                    System.out.println("⚠️ attendance field is missing or not a map");
                }
            } else {
                System.out.println("⚠️ attendance document does not exist for date: " +dateAttendance);
            }

            // 🔍 Debug log the attendance map here
            System.out.println("attendanceMap: " + attendanceMap);


            // Step 2: Fetch all students and filter those marked present
            ApiFuture<QuerySnapshot> studentFuture = db.collection("student").get();
            List<QueryDocumentSnapshot> studentDocs = studentFuture.get().getDocuments();

            for (QueryDocumentSnapshot doc : studentDocs) {
                String studentId = doc.getId();

                // Check if student ID exists in attendance map and is marked present
                if (attendanceMap.containsKey(studentId)) {
                    Object presentObj = attendanceMap.get(studentId);

                    if (presentObj instanceof Boolean && (Boolean) presentObj) {
                        Map<String, Object> student = new HashMap<>();
                        student.put("studentId", studentId);
                        student.put("fullName", doc.getString("fullName"));
                        studentList.add(student);
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("error2.html");
            return;
        }


        // Step 3: Forward to JSP
        request.setAttribute("studentList", studentList);
        request.setAttribute("activityId", activityId);
        request.setAttribute("focusArray", focusArray);
        request.setAttribute("date", dateAttendance);

        RequestDispatcher dispatcher = request.getRequestDispatcher("selectStudent.jsp");
        dispatcher.forward(request, response);
    }
}

