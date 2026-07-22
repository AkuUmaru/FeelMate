import 'package:flutter/material.dart';
import 'package:myapp/pages/dashboard/db1.dart';
import 'package:myapp/utils/colors.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Register',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    shadows: [
                      Shadow(
                        blurRadius: 5.0,
                        color: Colors.grey.shade300,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField('Username'),
                const SizedBox(height: 10),
                _buildTextField('Password', obscureText: true),
                const SizedBox(height: 10),
                _buildTextField('Confirm Password', obscureText: true),
                const SizedBox(height: 10),
                _buildTextField('Email'),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField('Day', isSmall: true),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTextField('Month', isSmall: true),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTextField('Year', isSmall: true),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildButton(context, 'Cancel', Colors.red, Colors.white,
                        () {
                      Navigator.pop(context);
                    }),
                    _buildButton(context, 'Submit', kPrimaryColor, Colors.white,
                        () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Db1()),
                        (route) => false,
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {},
                  child: const Text.rich(
                    TextSpan(
                      text: 'Have an account? ',
                      style: TextStyle(color: Colors.grey),
                      children: [
                        TextSpan(
                          text: 'Sign up here.',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildTextField(String hintText,
    {bool obscureText = false, bool isSmall = false}) {
  return TextField(
    obscureText: obscureText,
    decoration: InputDecoration(
      hintText: hintText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      contentPadding: isSmall
          ? const EdgeInsets.symmetric(vertical: 8, horizontal: 8)
          : const EdgeInsets.all(16),
    ),
  );
}

Widget _buildButton(
  BuildContext context,
  String text,
  Color color,
  Color textColor,
  VoidCallback onTap,
) {
  return ElevatedButton(
    onPressed: onTap,
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    child: Text(
      text,
      style: TextStyle(color: textColor),
    ),
  );
}
