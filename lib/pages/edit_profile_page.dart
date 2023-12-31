import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../services/shared_service.dart';
import '../utilities/constants.dart';
import '../utilities/snackbars.dart';
import '../utilities/themes.dart';
import '../widgets/circular_progress_indicator.dart';
import 'package:path/path.dart' as path;

class EditProfilePage extends StatefulWidget {
  static String routeName = '/editProfilePage';
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String userName = SharedService.userName;

  File? _selectedImage;
  String? _imageName;

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

  Future<void> updateProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid;
      if (_selectedImage != null) {
        await FirebaseStorage.instance
            .ref(
              'image_file/$userId/$_imageName',
            )
            .putFile(_selectedImage!);

        String imageUrl = await FirebaseStorage.instance
            .ref('image_file/$userId/$_imageName')
            .getDownloadURL();
        // ignore: use_build_context_synchronously
        await Provider.of<ProfileProvider>(context, listen: false)
            .updateProfile(
          userName,
          imageUrl,
        );

        return;
      } else {
        await Provider.of<ProfileProvider>(context, listen: false)
            .updateProfile(
          userName,
          SharedService.userImageUrl,
        );
      }
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    if (userName == SharedService.userName && _selectedImage == null) {
      SnackBars.showNormalSnackbar(context, 'No changes to save.');
      return;
    }
    setState(() {
      _isLoading = true;
    });

    await updateProfile().then((value) {
      Navigator.of(context).pop();
      SnackBars.showNormalSnackbar(context, 'Profile updated successfully.');
    }).catchError((e) {
      SnackBars.showErrorSnackBar(
        context,
        e.toString(),
      );
    });
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                MediaQuery.of(context).padding.bottom,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.26,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                                colors: [
                                  Colors.lightGreen,
                                  ThemeClass.primaryColor,
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 10,
                            left: 10,
                            child: IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(
                                Icons.navigate_before,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        flex: 10,
                        child: Container(
                          padding: const EdgeInsets.only(
                            top: 100,
                            right: 8,
                            bottom: 8,
                            left: 8,
                          ),
                          child: Column(
                            children: [
                              TextFormField(
                                initialValue:
                                    Provider.of<ProfileProvider>(context)
                                        .userName,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Username can\'t be empty';
                                  }
                                  if (value.length <= 6) {
                                    return 'Username should  be at least 7 characters.';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  border: border,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      10,
                                    ),
                                  ),
                                  errorBorder: errorBorder,
                                  focusedBorder: focusedBorder,
                                  focusedErrorBorder: focusedErrorBorder,
                                  label: const AutoSizeText(
                                    'Username',
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.person,
                                  ),
                                ),
                                onSaved: (text) {
                                  userName = text!;
                                },
                                onChanged: (text) {
                                  userName = text;
                                },
                              ),
                              SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.1),
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
                                              'Update Profile',
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
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.189,
                  left: 20,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(
                                10,
                              ),
                              border: Border.all(
                                color: Colors.grey,
                                width: 2,
                              ),
                            ),
                            child: _selectedImage == null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      10,
                                    ),
                                    child: Image(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(
                                          Provider.of<ProfileProvider>(context)
                                              .imageUrl),
                                    ),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      10,
                                    ),
                                    child: Image(
                                      fit: BoxFit.cover,
                                      image: FileImage(
                                        _selectedImage!,
                                      ),
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
                                        height:
                                            MediaQuery.of(context).size.height *
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
                                                    if (_selectedImage !=
                                                        null) {
                                                      Navigator.of(context)
                                                          .pop();
                                                    }
                                                  });
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets
                                                          .symmetric(
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
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: const [
                                                      Icon(
                                                        Icons
                                                            .camera_alt_outlined,
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
                                                    if (_selectedImage !=
                                                        null) {
                                                      Navigator.of(context)
                                                          .pop();
                                                    }
                                                  });
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 10,
                                                    vertical: 15,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        ThemeClass.primaryColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
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
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                      color: Colors.green, width: 0.5),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.edit,
                                    size: 22,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
