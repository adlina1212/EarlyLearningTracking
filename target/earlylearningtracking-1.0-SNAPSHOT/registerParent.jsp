<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Register Parent</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(to right, #74ebd5, #ACB6E5);
            padding: 40px;
            margin: 0;
        }

        .container {
            background-color: #ffffff;
            padding: 30px 40px;
            border-radius: 12px;
            max-width: 500px;
            margin: auto;
            box-shadow: 0 8px 16px rgba(0, 0, 0, 0.15);
        }

        h2 {
            text-align: center;
            margin-bottom: 25px;
            color: #333;
        }

        label {
            display: block;
            margin-top: 15px;
            font-weight: 600;
            color: #444;
        }

        input[type="text"],
        input[type="email"],
        input[type="password"],
        input[type="tel"] {
            width: 100%;
            padding: 12px 14px;
            margin-top: 6px;
            border: 1px solid #ccc;
            border-radius: 8px;
            box-sizing: border-box;
            transition: border-color 0.3s ease;
        }

        input:focus {
            border-color: #007bff;
            outline: none;
        }

        button {
            margin-top: 30px;
            width: 100%;
            padding: 14px;
            background-color: #007bff;
            border: none;
            color: white;
            font-size: 16px;
            font-weight: bold;
            border-radius: 8px;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }

        button:hover {
            background-color: #0056b3;
        }

        @media (max-width: 600px) {
            .container {
                padding: 20px;
            }
        }
    </style>

    <script>
        document.querySelector("form").addEventListener("submit", function(e) {
            const password = document.getElementById("password").value;
            const confirm = document.getElementById("confirmPassword").value;
            const postcode = document.getElementById("postcode").value;

            if (password !== confirm) {
                e.preventDefault();
                alert("Password and Confirm Password do not match.");
                return;
            }

            if (!/^\d{5}$/.test(postcode)) {
                e.preventDefault();
                alert("Postcode must be a 5-digit number.");
                return;
            }
        });
    </script>

</head>
<body>

<div class="container">
    <h2>Parent Registration</h2>
    <form action="registerParent" method="post">
        <label for="parentName">Full Name</label>
        <input type="text" id="parentName" name="parentName" required>

        <label for="parentIC">Identification Card</label>
        <input type="text" id="parentIC" name="parentIC" required>

        <label for="email">Email</label>
        <input type="email" id="email" name="email" required>

        <label for="phone">Phone Number</label>
        <input type="text" id="phone" name="phone" required>

        <label for="occupation">Occupation</label>
        <input type="text" id="occupation" name="occupation" required>
        
        <!-- Address fields -->
        <label for="address">Address</label>
        <input type="text" id="address" name="address" required>

        <label for="postcode">Postcode</label>
        <input type="text" id="postcode" name="postcode" required>

        <label for="city">City</label>
        <input type="text" id="city" name="city" required>

        <select id="state" name="state" required>
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

        <label for="password">Password</label>
        <input type="password" id="password" name="password" required>

        <label for="confirmPassword">Confirm Password</label>
        <input type="password" id="confirmPassword" required>

        <div id="errorMsg" class="error-message"></div>
        
        <button type="submit">Register</button>
    </form>
</div>

</body>
</html>
