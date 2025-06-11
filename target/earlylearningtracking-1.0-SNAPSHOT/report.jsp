<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!-- Firestore -->
<script src="https://www.gstatic.com/firebasejs/9.22.2/firebase-app.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.22.2/firebase-firestore.js"></script>

<!-- Chart.js -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<!-- jsPDF & html2canvas -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
<script src="https://html2canvas.hertzen.com/dist/html2canvas.min.js"></script>

<h2>Generate Annual Report</h2>

<label for="childSelect">Select Child:</label>
<select id="childSelect"></select>

<label for="ageSelect">Select Age:</label>
<select id="ageSelect">
    <option value="1-2">1–2 years</option>
    <option value="2-3">2–3 years</option>
</select>

<button onclick="generateReport()">Generate Report</button>

<hr>

<div id="reportPreviewContainer" style="display: none;">
    <h3>Preview Report</h3>

    <div id="reportContent" style="width: 800px; background: white; padding: 20px;">
        <h2>Annual Report</h2>
        <p><strong>Student Name:</strong> <span id="studentName"></span></p>
        <p><strong>Age Group:</strong> <span id="studentAge"></span></p>

        <canvas id="literacyChart" width="600" height="300"></canvas>
        <canvas id="physicalChart" width="600" height="300"></canvas>

        <h4>Teacher’s Comment</h4>
        <p id="teacherComment"></p>
    </div>

    <button onclick="downloadPDF()">Download PDF</button>
</div>
<script type="module">
import { initializeApp } from "https://www.gstatic.com/firebasejs/9.22.2/firebase-app.js";
import { getFirestore, collection, getDocs, query, where } from "https://www.gstatic.com/firebasejs/9.22.2/firebase-firestore.js";

// Firebase Config
const firebaseConfig = {
  apiKey: "YOUR_API_KEY",
  authDomain: "YOUR_AUTH_DOMAIN",
  projectId: "YOUR_PROJECT_ID",
  storageBucket: "YOUR_STORAGE_BUCKET",
  messagingSenderId: "YOUR_MSG_ID",
  appId: "YOUR_APP_ID"
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

// Load students
const childSelect = document.getElementById("childSelect");
const students = {};

async function loadStudents() {
    const studentSnapshot = await getDocs(collection(db, "student"));
    studentSnapshot.forEach(doc => {
        const data = doc.data();
        students[doc.id] = data;
        const option = document.createElement("option");
        option.value = doc.id;
        option.text = data.name || data.username;
        childSelect.appendChild(option);
    });
}
loadStudents();

// Generate Report
let literacyChart, physicalChart;

async function generateReport() {
    const studentId = childSelect.value;
    const ageGroup = document.getElementById("ageSelect").value;
    if (!studentId || !ageGroup) return alert("Please select both child and age group");

    const student = students[studentId];
    document.getElementById("studentName").innerText = student.name || student.username;
    document.getElementById("studentAge").innerText = ageGroup;

    // Get assessments
    const q = query(collection(db, "ActivityAssessment"), where("studentId", "==", studentId));
    const snapshot = await getDocs(q);

    const literacyData = {}, physicalData = {};
    let teacherComment = "";

    snapshot.forEach(doc => {
        const data = doc.data();
        const date = new Date(data.timestamp?.seconds * 1000).toLocaleString('default', { month: 'short' });

        // Assume data.achievement.literacy and .physical are arrays of integers
        const literacyAvg = average(data.achievement?.literacy || []);
        const physicalAvg = average(data.achievement?.physical || []);

        literacyData[date] = literacyAvg;
        physicalData[date] = physicalAvg;

        if (data.comment) teacherComment += `• ${data.comment}<br>`;
    });

    drawChart("literacyChart", literacyData, "Literacy Progress");
    drawChart("physicalChart", physicalData, "Physical Progress");
    document.getElementById("teacherComment").innerHTML = teacherComment || "No comments available.";

    document.getElementById("reportPreviewContainer").style.display = "block";
}

function average(arr) {
    if (!arr.length) return 0;
    return (arr.reduce((a, b) => a + b, 0) / arr.length).toFixed(1);
}

function drawChart(canvasId, data, label) {
    const ctx = document.getElementById(canvasId).getContext("2d");

    if (canvasId === "literacyChart" && literacyChart) literacyChart.destroy();
    if (canvasId === "physicalChart" && physicalChart) physicalChart.destroy();

    const chart = new Chart(ctx, {
        type: "bar",
        data: {
            labels: Object.keys(data),
            datasets: [{
                label: label,
                data: Object.values(data),
                backgroundColor: "rgba(54, 162, 235, 0.6)"
            }]
        },
        options: {
            scales: { y: { beginAtZero: true } }
        }
    });

    if (canvasId === "literacyChart") literacyChart = chart;
    if (canvasId === "physicalChart") physicalChart = chart;
}

// PDF Export
async function downloadPDF() {
    const { jsPDF } = window.jspdf;
    const doc = new jsPDF("p", "pt", "a4");
    const report = document.getElementById("reportContent");

    await html2canvas(report, { scale: 2 }).then(canvas => {
        const imgData = canvas.toDataURL("image/png");
        const imgProps = doc.getImageProperties(imgData);
        const pdfWidth = doc.internal.pageSize.getWidth();
        const pdfHeight = (imgProps.height * pdfWidth) / imgProps.width;

        doc.addImage(imgData, "PNG", 0, 0, pdfWidth, pdfHeight);
        doc.save(`${document.getElementById("studentName").innerText}_Annual_Report.pdf`);
    });
}
</script>
