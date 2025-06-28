<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>User Profile</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700&display=swap" rel="stylesheet">
    <style>
        body {
            margin: 0;
            font-family: 'Poppins', sans-serif;
            background-color: #f6f4fa;
            color: #333;
        }

        .top-nav {
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: linear-gradient(to right, #c7b5e5, #a78ccf);
            padding: 20px 40px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }

        .logo {
            font-weight: 700;
            font-size: 1.8em;
            color: #fff;
        }

        .logo span {
            color: #ede1ff;
        }

        .nav-links {
            list-style: none;
            display: flex;
            gap: 25px;
            padding: 0;
            margin: 0;
        }

        .nav-links li a {
            text-decoration: none;
            color: #fff;
            font-weight: 500;
            padding: 8px 16px;
            border-radius: 8px;
        }

        .nav-links li a:hover {
            background-color: rgba(255, 255, 255, 0.2);
        }

        .container {
            max-width: 800px;
            margin: 40px auto;
            padding: 30px;
            background-color: #fff;
            border-radius: 15px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.05);
        }

        h1 {
            color: #5e4b8b;
            font-size: 2em;
            margin-bottom: 25px;
        }

        .profile-card p {
            font-size: 1em;
            margin-bottom: 15px;
        }

        .profile-card input {
            padding: 10px 15px;
            font-size: 1em;
            border: 1px solid #ccc;
            border-radius: 8px;
            width: 100%;
            max-width: 400px;
            margin-top: 5px;
        }

        .edit-buttons {
            margin-top: 20px;
        }

        .edit-buttons button {
            padding: 10px 20px;
            border-radius: 25px;
            border: none;
            font-weight: 600;
            cursor: pointer;
            margin-right: 10px;
        }

        #editBtn {
            background-color: #a78ccf;
            color: white;
        }

        #updateBtn {
            background-color: #7a5ca0;
            color: white;
        }

        .cancel {
            background-color: #ccc;
            color: #333;
        }

        .back-button {
            display: inline-block;
            margin-top: 25px;
            color: #7a5ca0;
            text-decoration: none;
            font-weight: 500;
        }

        .back-button:hover {
            text-decoration: underline;
        }

        @media (max-width: 768px) {
            .top-nav {
                flex-direction: column;
                align-items: flex-start;
            }
            .nav-links {
                flex-direction: column;
                gap: 10px;
                margin-top: 15px;
            }
        }
    </style>
</head>
<body>

<!-- ✅ Top Navigation Bar -->
<nav class="top-nav">
    <div class="logo">parent<span>.</span></div>
    <ul class="nav-links">
        <li><a href="parentDashboard">Home</a></li>
        <li><a href="profile">Profile</a></li>
        <li><a href="logout">Logout</a></li>
    </ul>
</nav>

<!-- ✅ Main Profile Container -->
<div class="container">
    <h1>Your Profile</h1>

    <div class="profile-card">
        <p><strong>Username:</strong><br>${username}</p>
        <p><strong>Full Name:</strong><br>${fullName}</p>
        <p><strong>Role:</strong><br>${role}</p>

        <p><strong>Phone:</strong><br>
            <input type="text" id="phoneInput" value="${phone}" readonly>
        </p>

        <p><strong>Email:</strong><br>
            <input type="text" id="emailInput" value="${email}" readonly>
        </p>
    </div>

    <!-- ✅ Edit/Update/Cancel Buttons -->
    <div class="edit-buttons">
        <button id="editBtn" onclick="enableEdit()">Edit</button>
        <button id="updateBtn" onclick="updateProfile()" style="display: none;">Update</button>
        <button class="cancel" id="cancelBtn" onclick="cancelEdit()" style="display: none;">Cancel</button>
    </div>

    <a href="parentDashboard" class="back-button">← Back to Dashboard</a>
</div>

<!-- ✅ JavaScript Logic -->
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
