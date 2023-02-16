import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:yourteam/constants/colors.dart';
import 'package:yourteam/constants/constant_utils.dart';
import 'package:yourteam/constants/constants.dart';
import 'package:yourteam/methods/auth_methods.dart';
import 'package:yourteam/screens/auth/login_screen.dart';
import 'package:yourteam/screens/home_controller.dart';
import 'package:yourteam/screens/toppages/chat/chat_list_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool passObscure = true;
  TextEditingController? _usernameFieldController;
  TextEditingController? _emailFieldController;
  TextEditingController? _passFieldController;
  TextEditingController? _confirmPassFieldController;
  bool isEmailCorrect = false;

  @override
  void initState() {
    super.initState();
    _usernameFieldController = TextEditingController();
    _emailFieldController = TextEditingController();
    _passFieldController = TextEditingController();
    _confirmPassFieldController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameFieldController?.dispose();
    _emailFieldController?.dispose();
    _passFieldController?.dispose();
    _confirmPassFieldController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SizedBox(
          width: size.width,
          height: size.height,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const SizedBox(
                          height: 25,
                        ),
                        const Text(
                          'Create An Account',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: Color.fromRGBO(23, 35, 49, 1),
                              fontFamily: 'Poppins',
                              fontSize: 25,
                              letterSpacing:
                                  0 /*percentages not used in flutter. defaulting to zero*/,
                              fontWeight: FontWeight.bold,
                              height: 1),
                        ),
                        const Text(
                          'Enter your information to create an account',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: Color.fromRGBO(101, 123, 149, 1),
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              letterSpacing:
                                  0 /*percentages not used in flutter. defaulting to zero*/,
                              fontWeight: FontWeight.normal,
                              height: 1),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        SizedBox(
                          width: size.width / 1.3,
                          child: Column(
                            children: [
                              Column(
                                children: [
                                  Row(
                                    children: const [
                                      Text(
                                        'Username',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            color:
                                                Color.fromRGBO(23, 35, 49, 1),
                                            fontFamily: 'Poppins',
                                            fontSize: 15,
                                            letterSpacing: 0,
                                            fontWeight: FontWeight.bold,
                                            height: 1),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 70,
                                    child: TextFormField(
                                      controller: _usernameFieldController,
                                      onFieldSubmitted: (value) {},
                                      autofocus: false,
                                      obscureText: false,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(15),
                                          ),
                                        ),
                                        hintText: 'Enter username',
                                        filled: true,
                                        fillColor: Colors.white,
                                        hintStyle: TextStyle(
                                            color: Color.fromRGBO(
                                                102, 124, 150, 1),
                                            fontFamily: 'Poppins',
                                            fontSize: 13,
                                            letterSpacing:
                                                0 /*percentages not used in flutter. defaulting to zero*/,
                                            fontWeight: FontWeight.normal,
                                            height: 1),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Row(
                                    children: const [
                                      Text(
                                        'Email',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            color:
                                                Color.fromRGBO(23, 35, 49, 1),
                                            fontFamily: 'Poppins',
                                            fontSize: 15,
                                            letterSpacing: 0,
                                            fontWeight: FontWeight.bold,
                                            height: 1),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 70,
                                    child: TextFormField(
                                      controller: _emailFieldController,
                                      onChanged: (String? value) {
                                        if (value != null) {
                                          value = value.trim();
                                          if (!EmailValidator.validate(value)) {
                                            setState(() {
                                              isEmailCorrect = false;
                                            });
                                          } else {
                                            setState(() {
                                              isEmailCorrect = true;
                                            });
                                          }
                                        }
                                      },
                                      autofocus: false,
                                      obscureText: false,
                                      decoration: InputDecoration(
                                        border: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(15),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(15),
                                          ),
                                          borderSide: BorderSide(
                                            color: isEmailCorrect
                                                ? mainColor
                                                : Colors.red,
                                            // width: 1,
                                          ),
                                        ),
                                        hintText: 'Enter Email',
                                        filled: true,
                                        fillColor: Colors.white,
                                        hintStyle: const TextStyle(
                                            color: Color.fromRGBO(
                                                102, 124, 150, 1),
                                            fontFamily: 'Poppins',
                                            fontSize: 13,
                                            letterSpacing:
                                                0 /*percentages not used in flutter. defaulting to zero*/,
                                            fontWeight: FontWeight.normal,
                                            height: 1),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Row(
                                    children: const [
                                      Text(
                                        'Password',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            color:
                                                Color.fromRGBO(23, 35, 49, 1),
                                            fontFamily: 'Poppins',
                                            fontSize: 15,
                                            letterSpacing: 0,
                                            fontWeight: FontWeight.bold,
                                            height: 1),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 70,
                                    child: TextFormField(
                                      controller: _passFieldController,
                                      onFieldSubmitted: (value) {},
                                      autofocus: false,
                                      obscureText: passObscure,
                                      decoration: InputDecoration(
                                        suffixIcon: InkWell(
                                          onTap: () {
                                            setState(() {
                                              passObscure = !passObscure;
                                            });
                                          },
                                          child: Icon(!passObscure
                                              ? Icons.visibility
                                              : Icons.visibility_off),
                                        ),
                                        border: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(15),
                                          ),
                                        ),
                                        hintText: 'Enter Password',
                                        filled: true,
                                        fillColor: Colors.white,
                                        hintStyle: const TextStyle(
                                            color: Color.fromRGBO(
                                                102, 124, 150, 1),
                                            fontFamily: 'Poppins',
                                            fontSize: 13,
                                            letterSpacing: 0,
                                            fontWeight: FontWeight.normal,
                                            height: 1),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Row(
                                    children: const [
                                      Text(
                                        'Confirm Password',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            color:
                                                Color.fromRGBO(23, 35, 49, 1),
                                            fontFamily: 'Poppins',
                                            fontSize: 15,
                                            letterSpacing: 0,
                                            fontWeight: FontWeight.bold,
                                            height: 1),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 70,
                                    child: TextFormField(
                                      controller: _confirmPassFieldController,
                                      onFieldSubmitted: (value) {},
                                      autofocus: false,
                                      obscureText: passObscure,
                                      decoration: InputDecoration(
                                        suffixIcon: InkWell(
                                          onTap: () {
                                            setState(() {
                                              passObscure = !passObscure;
                                            });
                                          },
                                          child: Icon(!passObscure
                                              ? Icons.visibility
                                              : Icons.visibility_off),
                                        ),
                                        border: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(15),
                                          ),
                                        ),
                                        hintText: 'Confirm Password',
                                        filled: true,
                                        fillColor: Colors.white,
                                        hintStyle: const TextStyle(
                                            color: Color.fromRGBO(
                                                102, 124, 150, 1),
                                            fontFamily: 'Poppins',
                                            fontSize: 13,
                                            letterSpacing: 0,
                                            fontWeight: FontWeight.normal,
                                            height: 1),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                              onPressed: () {
                                register();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: mainColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0, 0, 0, 0),
                                minimumSize: const Size(306, 54),
                              ),
                              child: const Text(
                                'Register',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: Color.fromRGBO(255, 255, 255, 1),
                                    fontFamily: 'Poppins',
                                    fontSize: 15,
                                    letterSpacing:
                                        0 /*percentages not used in flutter. defaulting to zero*/,
                                    fontWeight: FontWeight.normal,
                                    height: 1),
                              )),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Already have an account?',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: Color.fromRGBO(23, 35, 49, 1),
                                  fontFamily: 'Poppins',
                                  fontSize: 15,
                                  letterSpacing:
                                      0 /*percentages not used in flutter. defaulting to zero*/,
                                  fontWeight: FontWeight.bold,
                                  height: 1),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen()));
                              },
                              child: const Text(
                                ' Login',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: mainColor,
                                    fontFamily: 'Poppins',
                                    fontSize: 15,
                                    letterSpacing:
                                        0 /*percentages not used in flutter. defaulting to zero*/,
                                    fontWeight: FontWeight.bold,
                                    height: 1),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                      ],
                    ),
                  ]),
            ),
          ),
        ),
      ),
    );
  }

  String checkEmpty(
      String name, String email, String password, String confirmPass) {
    String res = "One or more fields are empty";
    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPass.isEmpty) {
      return res;
    }
    return "continue";
  }

  void register() async {
    String checkValue = checkEmpty(
        _usernameFieldController!.text,
        _emailFieldController!.text,
        _passFieldController!.text,
        _confirmPassFieldController!.text);
    if (checkValue == "continue") {
      if (isEmailCorrect) {
        if (_passFieldController!.text == _confirmPassFieldController!.text) {
          setState(() {
            showFloatingFlushBar(context, "Please wait", "Registering");
          });
          String res = await AuthMethods().signUpUser(
              username: _usernameFieldController!.text.trim(),
              email: _emailFieldController!.text.trim(),
              password: _passFieldController!.text.trim());
          setState(() {
            if (res == "Success") {
              showFloatingFlushBar(context, "Success", "Please wait");
              _moveToNextScreen();
            } else {
              showFloatingFlushBar(context, "Error", res);
            }
          });
        } else {
          setState(() {
            showFloatingFlushBar(context, "Error", "Passwords doesn't match");
          });
        }
      } else {
        showFloatingFlushBar(context, "Error", "Please enter a correct email");
      }
    } else {
      showFloatingFlushBar(context, "Error", checkValue);
    }
  }

  _moveToNextScreen() {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeController()),
      );
    });
  }
}
