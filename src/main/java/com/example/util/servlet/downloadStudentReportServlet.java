package com.example.util.servlet;

import com.google.api.core.ApiFuture;
import com.google.cloud.Timestamp;
import com.google.cloud.firestore.*;
import com.google.firebase.cloud.FirestoreClient;
import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Map;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.concurrent.ExecutionException;

@WebServlet("/downloadStudentReport")
public class downloadStudentReportServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String studentId = request.getParameter("studentId");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");

        if (studentId == null || startDate == null || endDate == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing parameters");
            return;
        }

        Firestore db = FirestoreClient.getFirestore();

        try {
            // ✅ 1) Get student info
            DocumentSnapshot studentDoc = db.collection("student").document(studentId).get().get();
            if (!studentDoc.exists()) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Student not found");
                return;
            }

            String fullName = studentDoc.getString("fullName");
            String dob = studentDoc.getString("dob");
            String gender = studentDoc.getString("gender");
            int age = studentDoc.getLong("age").intValue();
            String ageGroup = "Unknown";
            if (age < 6) ageGroup = "0-6 months";
            else if (age < 12) ageGroup = "6-12 months";
            else if (age < 18) ageGroup = "12-18 months";
            else if (age < 24) ageGroup = "18-24 months";
            else if (age < 36) ageGroup = "24-36 months";

            // ✅ 2) Get assessments
            CollectionReference assessments = db.collection("ActivityAssessment");
            ApiFuture<QuerySnapshot> future = assessments.whereEqualTo("studentId", studentId).get();
            List<QueryDocumentSnapshot> docs = future.get().getDocuments();

            // ✅ 3) Filter & collect
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            Date start = sdf.parse(startDate);
            Date end = sdf.parse(endDate);

            Map<String, List<Integer>> literacy = new LinkedHashMap<>();
            Map<String, List<Integer>> physical = new LinkedHashMap<>();
            List<String> reflections = new ArrayList<>();

            for (QueryDocumentSnapshot doc : docs) {
                Timestamp ts = doc.getTimestamp("timestamp");
                if (ts == null) continue;
                Date tsDate = ts.toDate();
                if (tsDate.before(start) || tsDate.after(end)) continue;

                @SuppressWarnings("unchecked")
                Map<String, Object> achievement = (Map<String, Object>) doc.get("achievement");
                if (achievement != null) {
                    @SuppressWarnings("unchecked")
                    Map<String, Object> lit = (Map<String, Object>) achievement.get("literacy");
                    if (lit != null) {
                        for (String key : lit.keySet()) {
                            literacy.computeIfAbsent(key, k -> new ArrayList<>()).add(Integer.parseInt(lit.get(key).toString()));
                        }
                    }
                    @SuppressWarnings("unchecked")
                    Map<String, Object> phy = (Map<String, Object>) achievement.get("physical");
                    if (phy != null) {
                        for (String key : phy.keySet()) {
                            physical.computeIfAbsent(key, k -> new ArrayList<>()).add(Integer.parseInt(phy.get(key).toString()));
                        }
                    }
                    String comment = (String) achievement.get("teacherComment");
                    if (comment != null && !comment.isEmpty()) reflections.add(comment);
                }
            }

            // ✅ 4) Compute averages
            Map<String, Double> litAvg = new LinkedHashMap<>();
            for (Map.Entry<String, List<Integer>> entry : literacy.entrySet()) {
                litAvg.put(entry.getKey(), entry.getValue().stream().mapToInt(i -> i).average().orElse(0));
            }

            Map<String, Double> phyAvg = new LinkedHashMap<>();
            for (Map.Entry<String, List<Integer>> entry : physical.entrySet()) {
                phyAvg.put(entry.getKey(), entry.getValue().stream().mapToInt(i -> i).average().orElse(0));
            }

            // ✅ 5) Build PDF
            response.setContentType("application/pdf");
            response.setHeader("Content-Disposition", "attachment; filename=Student_Report.pdf");

            Document pdf = new Document();
            PdfWriter.getInstance(pdf, response.getOutputStream());
            pdf.open();

            pdf.add(new Paragraph("Student Report", FontFactory.getFont(FontFactory.HELVETICA_BOLD, 20)));
            pdf.add(new Paragraph(" "));

            pdf.add(new Paragraph("Name: " + fullName));
            pdf.add(new Paragraph("DOB: " + dob));
            pdf.add(new Paragraph("Gender: " + gender));
            pdf.add(new Paragraph("Age: " + age + " months"));
            pdf.add(new Paragraph("Age Group: " + ageGroup));
            pdf.add(new Paragraph("Date Range: " + startDate + " to " + endDate));
            pdf.add(new Paragraph(" "));

            pdf.add(new Paragraph("Literacy Averages:"));
            PdfPTable litTable = new PdfPTable(2);
            litTable.addCell("Criteria");
            litTable.addCell("Average");
            for (String key : litAvg.keySet()) {
                litTable.addCell(key);
                litTable.addCell(String.format("%.2f", litAvg.get(key)));
            }
            pdf.add(litTable);

            pdf.add(new Paragraph(" "));
            pdf.add(new Paragraph("Physical Averages:"));
            PdfPTable phyTable = new PdfPTable(2);
            phyTable.addCell("Criteria");
            phyTable.addCell("Average");
            for (String key : phyAvg.keySet()) {
                phyTable.addCell(key);
                phyTable.addCell(String.format("%.2f", phyAvg.get(key)));
            }
            pdf.add(phyTable);

            pdf.add(new Paragraph(" "));
            pdf.add(new Paragraph("Teacher Reflections:"));
            for (String ref : reflections) {
                pdf.add(new Paragraph("- " + ref));
            }

            pdf.close();

        } catch (InterruptedException | ExecutionException | com.itextpdf.text.DocumentException | java.text.ParseException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error generating PDF");
        }
    }
}
