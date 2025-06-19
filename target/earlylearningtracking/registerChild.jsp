<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Register Child</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="css/registerChild.css">
</head>
<body>

<div class="registration-container">
    <h2 style="display: flex; align-items: center; gap: 12px;">
        <img src="img/school.png" alt="Child Icon" style="width: 36px; height: 36px;">
        Register Child
    </h2>

    <form action="registerChildServlet" method="post" enctype="multipart/form-data">
        <div id="childFormsContainer">
            <div class="child-form">
                <h3>Child Information</h3>

                <label>Full Name</label>
                <input type="text" name="childName[]" required>

                <label>Date of Birth</label>
                <input type="date" name="dob[]" required>

                <label>Gender</label>
                <select name="gender[]" required>
                    <option value="">-- Select --</option>
                    <option value="Male">Male</option>
                    <option value="Female">Female</option>
                </select>

                <!--<label>Photo</label>
                <input type="file" name="photo[]" accept="image/*">-->

                <label>Allergies</label>
                <textarea name="allergies[]" rows="3" placeholder="List any known allergies..."></textarea>
            </div>
        </div>

        <div class="form-buttons">
            <button type="button" onclick="addChildForm()">+ Add Another Child</button>
            <button type="submit">Submit</button>
        </div>
    </form>
</div>

<script>
    function addChildForm() {
        const container = document.getElementById("childFormsContainer");
        const firstForm = document.querySelector(".child-form");
        const newForm = firstForm.cloneNode(true);

        newForm.querySelectorAll("input, select, textarea").forEach(input => {
            if (input.type === "file") input.value = null;
            else input.value = "";
        });

        container.appendChild(newForm);
    }
</script>

</body>
</html>
