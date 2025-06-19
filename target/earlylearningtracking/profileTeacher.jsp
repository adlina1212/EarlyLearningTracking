<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Profile</title>
    <link rel="stylesheet" href="css/profile.css">
</head>
<body>
    <div class="sidebar">
        <h2>Dashboard</h2>
        <nav>
            <a href="teacherDashboard">Home</a>
            <a href="profile">Profile</a>
            <a href="assessment">Assessment</a>
            <a href="logout">Logout</a>
        </nav>
    </div>

    <div class="profile-container">
        <h1>User Profile</h1>

        <div class="profile-card">
            <p><strong>Username:</strong> ${username}</p>
            <p><strong>Full name:</strong>${fullName}</p>
            <p><strong>Role:</strong> ${role}</p>

            <p><strong>Phone:</strong>
                <input type="text" id="phoneInput" class="editable" value="${phone}" readonly>
            </p>

            <p><strong>Email:</strong>
                <input type="text" id="emailInput" class="editable" value="${email}" readonly>
            </p>
        </div>

        <!-- Edit, Update, Cancel buttons -->
        <div class="edit-buttons">
            <button id="editBtn" onclick="enableEdit()">Edit</button>
            <button id="updateBtn" onclick="updateProfile()" style="display: none;">Update</button>
            <button class="cancel" id="cancelBtn" onclick="cancelEdit()" style="display: none;">Cancel</button>
        </div>

        <a href="teacherDashboard" class="back-button">← Back to Dashboard</a>

    </div>

    <script>
        const phoneInput = document.getElementById("phoneInput");
        const emailInput = document.getElementById("emailInput");
        const editBtn = document.getElementById("editBtn");
        const updateBtn = document.getElementById("updateBtn");
        const cancelBtn = document.getElementById("cancelBtn");

        
        const originalPhone = phoneInput.value;
        const originalEmail = emailInput.value;

        function enableEdit() {
            phoneInput.readOnly = false;
            emailInput.readOnly = false;
            editBtn.style.display = "none";
            updateBtn.style.display = "inline-block";
            cancelBtn.style.display = "inline-block";
        }

        function cancelEdit() {
            phoneInput.value = originalPhone;
            emailInput.value = originalEmail;
            phoneInput.readOnly = true;
            emailInput.readOnly = true;
            editBtn.style.display = "inline-block";
            updateBtn.style.display = "none";
            cancelBtn.style.display = "none";
        }

        function updateProfile() {
            const updatedPhone = phoneInput.value.trim();
            const updatedEmail = emailInput.value.trim();
            const userId = '${userId}';

            fetch("updateProfile", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json"
                },
                body: JSON.stringify({
                    userId: userId,
                    phone: updatedPhone,
                    email: updatedEmail
                })
            }).then(res => {
                if (res.ok) {
                    alert("Profile updated!");
                    phoneInput.readOnly = true;
                    emailInput.readOnly = true;
                    editBtn.style.display = "inline-block";
                    updateBtn.style.display = "none";
                    cancelBtn.style.display = "none";
                } else {
                    alert("Update failed.");
                }
            });
        }
    </script>
</body>
</html>
