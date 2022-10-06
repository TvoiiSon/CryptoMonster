<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CryptoMonster - Authorization</title>
</head>
<body>
    <h1>Pass Authorization</h1>
    <div class="form_auth_block">
        <div class="form_auth_block_content">
            <form class="form_auth_style" action="/" method="post">
                <label>Enter Your Login</label>
                <input type="text" name="username" placeholder="Enter Your Login" required >
                <label>Enter Your Password</label>
                <input type="password" name="password" placeholder="Enter Your Password" required >
                <label>Enter Your Second Password</label>
                <input type="password" name="secondpassword" placeholder="Enter Your Second Password" required >
                <button class="form_auth_button" type="submit" name="form_auth_submit">LogIn</button>
            </form>
        </div>
    </div>
</body>
</html>