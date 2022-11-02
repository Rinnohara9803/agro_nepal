import 'dart:io';
import 'package:agro_nepal/pages/forgot_password_page.dart';
import 'package:agro_nepal/pages/sign_in_page.dart';
import 'package:agro_nepal/pages/verify_email_page.dart';
import 'package:agro_nepal/providers/profile_provider.dart';
import 'package:agro_nepal/utilities/snackbars.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import '../services/apis/notifications_api.dart';
import '../utilities/themes.dart';
import '../widgets/circular_progress_indicator.dart';
import '../widgets/general_textformfield.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  static const routeName = '/signUpPage';

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool isVisible = true;
  final _userNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  File? _selectedImage;
  String? _imageName;

  String? _token = '';
  void getToken(String userId) async {
    await FirebaseMessaging.instance.getToken().then((token) {
      setState(() {
        _token = token;
      });
      print(_token);
      Notifications.saveToken(token!, userId);
    });
  }

  Future<void> _getUserPicture(ImageSource imageSource) async {
    ImagePicker picker = ImagePicker();
    final image = await picker.pickImage(
      source: imageSource,
    );
    if (image == null) {
      return;
    }
    _imageName = path.basename(image.path);

    setState(() {
      _selectedImage = File(image.path);
    });
  }

  final auth = FirebaseAuth.instance;
  late UserCredential userCredential;

  Future<void> _saveForm() async {
    if (_selectedImage == null) {
      SnackBars.showErrorSnackBar(context, 'Please provide your image.');
      return;
    } else if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    _formKey.currentState!.save();
    try {
      setState(() {
        _isLoading = true;
      });

      userCredential = await auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      await FirebaseStorage.instance
          .ref(
            'image_file/${userCredential.user!.uid}/$_imageName',
          )
          .putFile(_selectedImage!);

      String imageUrl = await FirebaseStorage.instance
          .ref('image_file/${userCredential.user!.uid}/$_imageName')
          .getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(
            userCredential.user!.uid,
          )
          .set(
        {
          'userId': userCredential.user!.uid,
          'userName': _userNameController.text,
          'email': _emailController.text,
          'imageUrl': imageUrl,
          'tag': 'user',
        },
      ).then((_) async {
        getToken(FirebaseAuth.instance.currentUser!.uid);
        await Provider.of<ProfileProvider>(context, listen: false)
            .fetchProfile()
            .then((value) {
          Navigator.pushReplacementNamed(
            context,
            VerifyEmailPage.routeName,
          );
        });
      });
    } on SocketException catch (_) {
      SnackBars.showNoInternetConnectionSnackBar(context);
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occured. Please try again later.';

      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'The account already exists for that email.';
      } else if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided for that user.';
      }

      SnackBars.showErrorSnackBar(context, errorMessage);

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.only(
              left: 10,
              right: 10,
              top: 10,
            ),
            height: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                MediaQuery.of(context).padding.top,
            width: MediaQuery.of(context).size.width,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: Container(),
                  ),
                  Image.asset(
                    'images/planting.png',
                    height: 90,
                    width: 90,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  AutoSizeText(
                    'Sign Up',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ThemeClass.primaryColor,
                      fontSize: 30,
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Stack(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.black,
                        radius: MediaQuery.of(context).devicePixelRatio * 20,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: MediaQuery.of(context).devicePixelRatio * 19,
                          backgroundImage: _selectedImage == null
                              ? null
                              : FileImage(
                                  _selectedImage!,
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: MediaQuery.of(context).devicePixelRatio,
                        right: MediaQuery.of(context).devicePixelRatio,
                        child: InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  elevation: 10,
                                  backgroundColor: Colors.white,
                                  child: Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.18,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 20,
                                      horizontal: 10,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: InkWell(
                                            onTap: () async {
                                              await _getUserPicture(
                                                ImageSource.camera,
                                              ).then((value) {
                                                if (_selectedImage != null) {
                                                  Navigator.of(context).pop();
                                                }
                                              });
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 15),
                                              decoration: BoxDecoration(
                                                color: const Color.fromRGBO(
                                                  239,
                                                  236,
                                                  236,
                                                  1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: const [
                                                  Icon(
                                                    Icons.camera_alt_outlined,
                                                    size: 15,
                                                    color: Color.fromRGBO(
                                                        81, 81, 81, 1),
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    "Open Camera",
                                                    style: TextStyle(
                                                      color: Color.fromRGBO(
                                                          81, 81, 81, 1),
                                                      fontFamily:
                                                          "circularstd-book",
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 14,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: InkWell(
                                            onTap: () async {
                                              await _getUserPicture(
                                                ImageSource.gallery,
                                              ).then((value) {
                                                if (_selectedImage != null) {
                                                  Navigator.of(context).pop();
                                                }
                                              });
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 15,
                                              ),
                                              decoration: BoxDecoration(
                                                color: ThemeClass.primaryColor,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: const [
                                                  Icon(
                                                    Icons.upload_outlined,
                                                    size: 15,
                                                    color: Colors.white,
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    "Upload",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontFamily:
                                                          "circularstd-book",
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 14,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: const Color.fromRGBO(199, 0, 42, 1),
                                  width: 0.5),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.add,
                                color: Color.fromRGBO(199, 0, 42, 1),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  GeneralTextFormField(
                    hasPrefixIcon: true,
                    hasSuffixIcon: false,
                    controller: _userNameController,
                    label: 'Full Name',
                    validator: (value) {
                      if (value!.trim().isEmpty) {
                        return 'Please enter your username.';
                      } else if (value.length <= 6) {
                        return 'Username should be at least 6 characters.';
                      }
                      return null;
                    },
                    textInputType: TextInputType.name,
                    iconData: Icons.person,
                    autoFocus: false,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  GeneralTextFormField(
                    hasPrefixIcon: true,
                    hasSuffixIcon: false,
                    controller: _emailController,
                    label: 'Email',
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@') || !value.endsWith('.com')) {
                        return 'Invalid email!';
                      }
                      return null;
                    },
                    textInputType: TextInputType.emailAddress,
                    iconData: Icons.mail_outline,
                    autoFocus: false,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  GeneralTextFormField(
                    hasPrefixIcon: true,
                    hasSuffixIcon: true,
                    controller: _passwordController,
                    label: 'Password',
                    validator: (value) {
                      if (value!.trim().isEmpty) {
                        return 'Please enter your password.';
                      } else if (value.trim().length < 6) {
                        return 'Please enter at least 6 characters.';
                      }
                      return null;
                    },
                    textInputType: TextInputType.name,
                    iconData: Icons.lock,
                    autoFocus: false,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                              context, ForgotPasswordPage.routeName);
                        },
                        child: AutoSizeText(
                          'Forgot Password ?',
                          style: TextStyle(
                            color: ThemeClass.primaryColor,
                            fontSize: 15,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Material(
                    elevation: 10,
                    borderRadius: BorderRadius.circular(
                      10,
                    ),
                    child: InkWell(
                      onTap: () async {
                        await _saveForm();
                      },
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: ThemeClass.primaryColor,
                          borderRadius: BorderRadius.circular(
                            10,
                          ),
                        ),
                        child: Center(
                          child: _isLoading
                              ? const ProgressIndicator1()
                              : const AutoSizeText(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AutoSizeText(
                        'Already have an account ? ',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 15,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context)
                              .pushReplacementNamed(SignInPage.routeName);
                        },
                        child: AutoSizeText(
                          'Sign In',
                          style: TextStyle(
                            color: ThemeClass.primaryColor,
                            fontSize: 15,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
