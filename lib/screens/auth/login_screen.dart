import 'package:flutter/material.dart';
import 'package:japan_app/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(textAlign: TextAlign.left, "Email : "),
            Padding(padding: EdgeInsets.all(4.0)),
            TextField(
              decoration: InputDecoration(
                hint: Text('exemple@lemail.com'),
                border: OutlineInputBorder(),
              ),
              controller: email,
            ),
            Padding(padding: EdgeInsets.all(10.0)),
            Text(textAlign: TextAlign.left, "Password : "),
            Padding(padding: EdgeInsets.all(4.0)),
            TextField(
              decoration: InputDecoration(
                hint: Text('abscdefg'),
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              controller: password,
            ),
            Padding(padding: EdgeInsets.all(4.0)),
            ElevatedButton(
              onPressed:() async {
                await AuthService().signIn(email.text, password.text);
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => const MapScreen()),
                // );
              },
              child: Text('Login'),
            ),
            ElevatedButton(
              onPressed: () async {
                await AuthService().signUp(email.text, password.text);
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => const MapScreen()),
                // );
              },
              child: Text('SignUp'),
            ),
          ],
        ),
      ),
    );
  }
}
