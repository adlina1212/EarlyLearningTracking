<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Login</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="css/login.css">
</head>
<body>

<div class="container">
    <div class="login-card">
        <div class="login-left">
            <img src="img/father.png" alt="Welcome Illustration">
            <h2>Welcome Back!</h2>
            <p>Track your child's early learning journey with us.</p>
        </div>
        <div class="login-right">
            <h2>Login</h2>
            <form action="/earlylearningtracking/login" method="POST">
                <label for="username">Username</label>
                <input type="text" name="username" id="username" required>

                <label for="password">Password</label>
                <input type="password" name="password" id="password" required>

                <div class="show-password">
                    <input type="checkbox" id="togglePassword">
                    <label for="togglePassword">Show Password</label>
                </div>

                <button type="submit">Login</button>

                <div class="register-link">
                    <a href="registerParent.jsp">Register as Parent</a>
                </div>

                <div class="error">
                    <script>
                        const urlParams = new URLSearchParams(window.location.search);
                        const error = urlParams.get('error');
                        if (error) document.write(decodeURIComponent(error));
                    </script>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    document.getElementById('togglePassword').addEventListener('change', function () {
        const pw = document.getElementById('password');
        pw.type = this.checked ? 'text' : 'password';
    });
</script>

</body>
</html>
