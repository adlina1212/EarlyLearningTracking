<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Parent Registration</title>
    <link rel="stylesheet" href="css/parentRegister.css" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>
<div class="wrapper">
    <div class="card">
        <div class="left-panel">
            <img src="images/parent-register.svg" alt="Illustration" />
            <h3>Join our learning family!</h3>
            <p>Track and support your child's growth with ease and care.</p>
        </div>

        <div class="right-panel">
            <h2>Parent Registration</h2>
            <form action="registerParent" method="post">
                <div class="row">
                    <div>
                        <label>Full Name</label>
                        <input type="text" name="parentName" required>
                    </div>
                    <div>
                        <label>IC Number</label>
                        <input type="text" name="parentIC" required>
                    </div>
                </div>

                <div class="row">
                    <div>
                        <label>Email</label>
                        <input type="email" name="email" required>
                    </div>
                    <div>
                        <label>Phone</label>
                        <input type="text" name="phone" required>
                    </div>
                </div>

                <label>Occupation</label>
                <input type="text" name="occupation" required>

                <label>Address</label>
                <input type="text" name="address" required>

                <div class="row">
                    <div>
                        <label>Postcode</label>
                        <input type="text" name="postcode" id="postcode" required>
                    </div>
                    <div>
                        <label>City</label>
                        <input type="text" name="city" required>
                    </div>
                </div>

                <label>State</label>
                <select name="state" required>
                    <option value="">-- Select State --</option>
                    <option value="Johor">Johor</option>
                    <option value="Kedah">Kedah</option>
                    <option value="Kelantan">Kelantan</option>
                    <option value="Melaka">Melaka</option>
                    <option value="Negeri Sembilan">Negeri Sembilan</option>
                    <option value="Pahang">Pahang</option>
                    <option value="Penang">Penang</option>
                    <option value="Perak">Perak</option>
                    <option value="Perlis">Perlis</option>
                    <option value="Sabah">Sabah</option>
                    <option value="Sarawak">Sarawak</option>
                    <option value="Selangor">Selangor</option>
                    <option value="Terengganu">Terengganu</option>
                    <option value="Kuala Lumpur">Kuala Lumpur</option>
                    <option value="Putrajaya">Putrajaya</option>
                    <option value="Labuan">Labuan</option>
                </select>

                <div class="row">
                    <div>
                        <label>Password</label>
                        <input type="password" id="password" name="password" required>
                    </div>
                    <div>
                        <label>Confirm Password</label>
                        <input type="password" id="confirmPassword" required>
                    </div>
                </div>

                <button type="submit">Register</button>
            </form>
        </div>
    </div>
</div>

<script>
    document.querySelector("form").addEventListener("submit", function(e) {
        const password = document.getElementById("password").value;
        const confirm = document.getElementById("confirmPassword").value;
        const postcode = document.getElementById("postcode").value;

        if (password !== confirm) {
            e.preventDefault();
            alert("Passwords do not match.");
            return;
        }

        if (!/^\d{5}$/.test(postcode)) {
            e.preventDefault();
            alert("Postcode must be 5 digits.");
            return;
        }
    });
</script>
</body>
</html>
