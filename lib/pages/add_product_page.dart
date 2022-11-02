import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products_provider.dart';
import '../utilities/constants.dart';
import '../utilities/snackbars.dart';
import '../utilities/themes.dart';
import '../widgets/circular_progress_indicator.dart';
import '../widgets/general_textformfield.dart';
import 'package:path/path.dart' as path;

class AddProductPage extends StatefulWidget {
  const AddProductPage({Key? key}) : super(key: key);

  static const routeName = '/add_user_product_page';

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  List<String> categories = [
    'Fruits',
    'Vegetables',
    'Seeds',
    'Fertilizers',
    'Machineries',
  ];
  List<String> sellingUnits = [
    'per KG',
    'per dozen',
    'per piece',
  ];

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

  File? _selectedImage;
  String? _imageName;

  final productNameController = TextEditingController();
  final productDescriptionController = TextEditingController();
  final priceController = TextEditingController();

  String category = '';
  String sellingUnit = '';

  bool isLoading = false;
  bool hasErrors = false;

  final _formKey = GlobalKey<FormState>();

  Future<void> _saveForm() async {
    final isValidated = _formKey.currentState!.validate();
    if (_selectedImage == null) {
      SnackBars.showErrorSnackBar(context, 'Please provide your image.');
      return;
    } else if (!isValidated) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      isLoading = true;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid;
      await FirebaseStorage.instance
          .ref(
            'image_file/$userId/$_imageName',
          )
          .putFile(_selectedImage!);

      String imageUrl = await FirebaseStorage.instance
          .ref('image_file/$userId/$_imageName')
          .getDownloadURL();
      // ignore: use_build_context_synchronously
      await Provider.of<ProductsProvider>(context, listen: false).addProduct(
        Product(
          productId: DateTime.now().toIso8601String(),
          productImageUrl: imageUrl,
          productName: productNameController.text,
          productDescription: productDescriptionController.text,
          category: category,
          sellingUnit: sellingUnit,
          price: double.parse(priceController.text),
        ),
      );
    } catch (e) {
      setState(() {
        hasErrors = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
      if (hasErrors == false) {
        SnackBars.showNormalSnackbar(context, 'Product added successfully!!!');
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Product'),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 15,
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        GeneralTextFormField(
                          hasPrefixIcon: true,
                          hasSuffixIcon: false,
                          controller: productNameController,
                          label: 'Product Name',
                          validator: (value) {
                            if (value!.trim().isEmpty) {
                              return 'Field is required.';
                            }
                            return null;
                          },
                          textInputType: TextInputType.name,
                          iconData: Icons.agriculture,
                          autoFocus: false,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        GeneralTextFormField(
                          hasPrefixIcon: true,
                          hasSuffixIcon: false,
                          controller: productDescriptionController,
                          label: 'Product Description',
                          validator: (value) {
                            if (value!.trim().isEmpty) {
                              return 'Field is required.';
                            } else if (value.length <= 6) {
                              return 'Username should be at least 6 characters.';
                            }
                            return null;
                          },
                          textInputType: TextInputType.name,
                          iconData: Icons.description,
                          autoFocus: false,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        DropdownButtonFormField(
                          decoration: InputDecoration(
                            isDense: true,
                            border: border,
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  width: 1.5, color: Colors.black54),
                              borderRadius: BorderRadius.circular(
                                10,
                              ),
                            ),
                            errorBorder: errorBorder,
                            focusedBorder: focusedBorder,
                            focusedErrorBorder: focusedErrorBorder,
                            label: const Text(
                              'Category',
                            ),
                          ),
                          items: categories.map(
                            (category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              );
                            },
                          ).toList(),
                          onChanged: (value) {
                            category = value as String;
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a category';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        DropdownButtonFormField(
                          decoration: InputDecoration(
                            isDense: true,
                            border: border,
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  width: 1.5, color: Colors.black54),
                              borderRadius: BorderRadius.circular(
                                10,
                              ),
                            ),
                            errorBorder: errorBorder,
                            focusedBorder: focusedBorder,
                            focusedErrorBorder: focusedErrorBorder,
                            label: const Text(
                              'Selling Unit',
                            ),
                          ),
                          items: sellingUnits.map(
                            (sellingUnit) {
                              return DropdownMenuItem(
                                value: sellingUnit,
                                child: Text(sellingUnit),
                              );
                            },
                          ).toList(),
                          onChanged: (value) {
                            sellingUnit = value as String;
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a sellingUnit';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        GeneralTextFormField(
                          hasPrefixIcon: true,
                          hasSuffixIcon: false,
                          controller: priceController,
                          label: 'Price',
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'The field is required.';
                            }
                            if (double.tryParse(value) == null) {
                              return 'please provide a valid Number';
                            }
                            if (double.parse(value) <= 0) {
                              return 'please enter a valid Number.';
                            }
                            return null;
                          },
                          textInputType: TextInputType.number,
                          iconData: Icons.price_change_sharp,
                          autoFocus: false,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 70,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    15,
                                  ),
                                ),
                                child: _selectedImage == null
                                    ? null
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          15,
                                        ),
                                        child: Image(
                                          fit: BoxFit.cover,
                                          image: FileImage(
                                            _selectedImage!,
                                          ),
                                        ),
                                      ), //a,
                              ),
                            ),
                            Expanded(
                              child: TextButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return Dialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        elevation: 10,
                                        backgroundColor: Colors.white,
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
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
                                                      color:
                                                          const Color.fromRGBO(
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
                                                            color:
                                                                Color.fromRGBO(
                                                                    81,
                                                                    81,
                                                                    81,
                                                                    1),
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
                                                      color: ThemeClass
                                                          .primaryColor,
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
                                child: const Text(
                                  'Add Photo',
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  Material(
                    elevation: 10,
                    borderRadius: BorderRadius.circular(
                      10,
                    ),
                    child: InkWell(
                      onTap: () {
                        _saveForm();
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
                          child: isLoading
                              ? const ProgressIndicator1()
                              : const Center(
                                  child: AutoSizeText(
                                    'Add Product',
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
