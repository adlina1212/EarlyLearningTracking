<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Teacher Profile</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600&display=swap" rel="stylesheet">
    <style>
        body {
            margin: 0;
            padding: 0;
            font-family: 'Poppins', sans-serif;
            background-color: #f8f6fc;
        }

        .top-nav {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 20px 50px;
            background: linear-gradient(to right, #b295d9, #c7aefc);
            color: #fff;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
        }

        .top-nav .logo {
            font-size: 24px;
            font-weight: 700;
        }

        .top-nav .logo span {
            color: #fff;
        }

        .nav-links {
            list-style: none;
            display: flex;
            gap: 25px;
            margin: 0;
        }

        .nav-links li a {
            color: white;
            text-decoration: none;
            font-weight: 500;
        }

        .nav-links li a:hover {
            text-decoration: underline;
        }

        .profile-container {
            max-width: 700px;
            margin: 50px auto;
            background-color: white;
            padding: 40px;
            border-radius: 20px;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.05);
        }

        .profile-container h1 {
            text-align: center;
            color: #6c4aab;
            margin-bottom: 30px;
        }

        .profile-card p {
            font-size: 16px;
            margin: 12px 0;
            color: #333;
        }

        .profile-card strong {
            display: inline-block;
            width: 120px;
            color: #5c3fa2;
        }

        .editable {
            padding: 8px 12px;
            width: 60%;
            border: 1px solid #ccc;
            border-radius: 8px;
        }

        .edit-buttons {
            text-align: center;
            margin-top: 20px;
        }

        .edit-buttons button {
            margin: 0 10px;
            padding: 10px 20px;
            border-radius: 25px;
            border: none;
            font-weight: bold;
            cursor: pointer;
        }

        #editBtn {
            background-color: #b28ed7;
            color: white;
        }

        #updateBtn {
            background-color: #6c4aab;
            color: white;
        }

        #cancelBtn {
            background-color: #e0d4f6;
            color: #5c3fa2;
        }

        .back-button {
            display: block;
            text-align: center;
            margin-top: 30px;
            text-decoration: none;
            color: #865dc6;
            font-weight: 500;
        }

        .back-button:hover {
            text-decoration: underline;
        }

        @media screen and (max-width: 768px) {
            .editable {
                width: 100%;
            }

            .top-nav {
                flex-direction: column;
                align-items: flex-start;
            }

            .nav-links {
                flex-direction: column;
                margin-top: 10px;
                gap: 10px;
            }
        }
    </style>
</head>
<body>

<!-- Top Navigation Bar -->
<nav class="top-nav">
    <div class="logo">teacher<span>.</span></div>
    <ul class="nav-links">
        <li><a href="teacherDashboard">Home</a></li>
        <li><a href="profile">Profile</a></li>
        <li><a href="assessment">Assessment</a></li>
        <li><a href="studentReport">Student Report</a></li>
        <li><a href="logout">Logout</a></li>
    </ul>
</nav>

<!-- Profile Card -->
<div class="profile-container">
    <h1>Your Profile</h1>

    <div class="profile-card">
        <p><strong>Username:</strong> ${username}</p>
        <p><strong>Full Name:</strong> ${fullName}</p>
        <p><strong>Role:</strong> ${role}</p>

        <p><strong>Phone:</strong>
            <input type="text" id="phoneInput" class="editable" value="${phone}" readonly>
        </p>

        <p><strong>Email:</strong>
            <input type="text" id="emailInput" class="editable" value="${email}" readonly>
        </p>
    </div>

    <div class="edit-buttons">
        <button id="editBtn" onclick="enableEdit()">Edit</button>
        <button id="updateBtn" onclick="updateProfile()" style="display: none;">Update</button>
        <button id="cancelBtn" onclick="cancelEdit()" style="display: none;">Cancel</button>
    </div>

    <a href="teacherDashboard" class="back-button">← Back to Dashboard</a>
</div>

<!-- Script for Edit/Update -->
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
