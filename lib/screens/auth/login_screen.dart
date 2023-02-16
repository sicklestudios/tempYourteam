import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:yourteam/constants/colors.dart';
import 'package:yourteam/constants/constant_utils.dart';
import 'package:yourteam/constants/constants.dart';
import 'package:yourteam/methods/auth_methods.dart';
import 'package:yourteam/screens/auth/register_screen.dart';
import 'package:yourteam/screens/home_controller.dart';
import 'package:yourteam/screens/toppages/chat/chat_list_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool passObscure = true;
  TextEditingController? _usernameFieldController;
  TextEditingController? _passFieldController;
  bool isEmailCorrect = false;

  @override
  void initState() {
    super.initState();
    _usernameFieldController = TextEditingController();
    _passFieldController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameFieldController?.dispose();
    _passFieldController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        body:
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Column(
            children: [
              const SizedBox(
                height: 25,
              ),
              const Text(
                'Welcome Back!',
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
                'Log in to your account',
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
                    Row(
                      children: const [
                        Text(
                          'Email',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: Color.fromRGBO(23, 35, 49, 1),
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
                          border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(15),
                            ),
                            borderSide: BorderSide(
                              color: isEmailCorrect ? mainColor : Colors.red,
                              // width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(15),
                            ),
                            borderSide: BorderSide(
                              color: isEmailCorrect ? mainColor : Colors.red,
                              // width: 1,
                            ),
                          ),
                          hintText: 'Enter Email',
                          filled: true,
                          fillColor: Colors.white,
                          hintStyle: const TextStyle(
                              color: Color.fromRGBO(102, 124, 150, 1),
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              letterSpacing:
                                  0 /*percentages not used in flutter. defaulting to zero*/,
                              fontWeight: FontWeight.normal,
                              height: 1),
                        ),
                      ),
                    ),
                    Row(
                      children: const [
                        Text(
                          'Password',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: Color.fromRGBO(23, 35, 49, 1),
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
                              color: Color.fromRGBO(102, 124, 150, 1),
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
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () async {
                        if (isEmailCorrect) {
                          String res = await AuthMethods().resetPassword(
                              email: _usernameFieldController!.text.trim());
                          if (res == "sent") {
                            showFloatingFlushBar(context, "Success",
                                "Password reset email has been sent");
                          } else {
                            showFloatingFlushBar(context, "Error", res);
                          }
                        } else {
                          showFloatingFlushBar(
                              context, "Error", "Please enter a correct email");
                        }
                      },
                      child: const Text(
                        'Forgot Password?',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            color: mainColor,
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            letterSpacing:
                                0 /*percentages not used in flutter. defaulting to zero*/,
                            fontWeight: FontWeight.bold,
                            height: 1),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    login();
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                    minimumSize: const Size(306, 54),
                  ),
                  child: const Text(
                    'Login',
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
            ],
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Don’t have an account?',
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
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const RegisterScreen()));
                    },
                    child: const Text(
                      ' Register',
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
                height: 20,
              ),
            ],
          ),
        ]),
      ),
    );
  }

  String checkEmpty(String email, String password) {
    String res = "One or more fields are empty";

    if (email.isNotEmpty) {
      if (password.isNotEmpty) {
        return "continue";
      } else {
        return res;
      }
    } else {
      return res;
    }
  }

  void login() async {
    String checkValue =
        checkEmpty(_usernameFieldController!.text, _passFieldController!.text);
    if (checkValue == "continue") {
      if (isEmailCorrect) {
        setState(() {
          showFloatingFlushBar(context, "Please wait", "Logging in");
        });
        String res = await AuthMethods().loginUser(
            email: _usernameFieldController!.text.trim(),
            password: _passFieldController!.text.trim(),
            context: context);
        setState(() {
          if (res == "Success") {
            showFloatingFlushBar(context, "Success", "Please wait");
            _moveToNextScreen();
          } else {
            showFloatingFlushBar(context, "Error", res);
          }
        });
      } else {
        showFloatingFlushBar(context, "Error", "Please enter a correct email");
      }
    } else {
      showFloatingFlushBar(context, "Error", checkValue);
    }
  }

  _moveToNextScreen() {
    Future.delayed(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeController()),
      );
    });
  }
}
