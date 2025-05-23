<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Register Child</title>
    <link rel="stylesheet" type="text/css" href="css/registerChild.css">
    <script>
        function addChildForm() {
            const childFormsContainer = document.getElementById("childFormsContainer");
            const newForm = document.querySelector(".child-form").cloneNode(true);
            newForm.querySelectorAll("input, textarea").forEach(input => input.value = "");
            childFormsContainer.appendChild(newForm);
        }
    </script>
</head>
<body>

<div class="registration-container">
    <h2>Child Registration Form</h2>

    <form action="registerChildServlet" method="post" enctype="multipart/form-data">
        <div id="childFormsContainer">
            <div class="child-form">
                <h3>Child Information</h3>
                <label>Child's Full Name:</label>
                <input type="text" name="childName" required><br>

                <label>Date of Birth:</label>
                <input type="date" name="dob" required><br>

                <label>Gender:</label>
                <select name="gender" required>
                    <option value="">--Select--</option>
                    <option value="Male">Male</option>
                    <option value="Female">Female</option>
                </select><br>

                <label>Photo:</label>
                <input type="file" name="photo" accept="image/*"><br>

                <label>Allergies:</label>
                <textarea name="allergies" rows="3" placeholder="List any known allergies"></textarea><br>
            </div>
        </div>

        <div class="form-buttons">
            <button type="button" onclick="addChildForm()">Add Another Child</button>
            <button type="submit">Submit</button>
        </div>
    </form>
</div>

</body>
</html>
