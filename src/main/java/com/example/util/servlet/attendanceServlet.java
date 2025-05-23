package com.example.util.servlet;

import com.google.cloud.firestore.Firestore;
import com.google.firebase.cloud.FirestoreClient;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;


@WebServlet("/submitAttendance")
public class attendanceServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Firestore db = FirestoreClient.getFirestore();
        String today = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
        Map<String, String[]> params = request.getParameterMap();

         // Map to hold the student IDs and their attendance status
        Map<String, Boolean> attendanceMap = new HashMap<>();

        for (String param : params.keySet()) {
            if (param.startsWith("attendance_")) {
                String studentId = param.replace("attendance_", "");
                String status = params.get(param)[0];
                boolean present = status.equalsIgnoreCase("yes");

                attendanceMap.put(studentId, present);
            }
        }

        // Build the Firestore document for the attendance record
    Map<String, Object> attendanceData = new HashMap<>();
    attendanceData.put("date", today);
    attendanceData.put("attendance", attendanceMap);

    try {
        // Save under the "attendance" collection with the date as the document ID
        db.collection("attendance").document(today).set(attendanceData).get();
        System.out.println("Attendance saved for " + today);
    } catch (Exception e) {
        e.printStackTrace();
    }
        response.sendRedirect("teacherDashboard");
    }
}
