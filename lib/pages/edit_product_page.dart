import 'dart:io';
import 'package:agro_nepal/utilities/snackbars.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products_provider.dart';
import '../utilities/constants.dart';
import '../utilities/themes.dart';
import '../widgets/circular_progress_indicator.dart';
import 'package:path/path.dart' as path;

class EditProductPage extends StatefulWidget {
  final Product product;
  const EditProductPage({
    Key? key,
    required this.product,
  }) : super(key: key);

  static const routeName = '/edit_user_product_page';

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
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
  String productName = '';
  String productDescription = '';
  String price = '';
  String category = '';
  String sellingUnit = '';

  bool isLoading = false;
  bool hasErrors = false;

  final _formKey = GlobalKey<FormState>();

  Future<void> _saveForm(Product product) async {
    final isValidated = _formKey.currentState!.validate();
    if (!isValidated) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      isLoading = true;
    });
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
        await Provider.of<ProductsProvider>(context, listen: false).editProduct(
          Product(
            productId: product.productId,
            productImageUrl: imageUrl,
            productName: product.productName,
            productDescription: product.productDescription,
            category: product.category,
            sellingUnit: product.sellingUnit,
            price: product.price,
          ),
        );
        return;
      } else {
        await Provider.of<ProductsProvider>(context, listen: false)
            .editProduct(product);
      }
    } catch (e) {
      setState(() {
        hasErrors = true;
      });
      SnackBars.showNormalSnackbar(
        context,
        e.toString(),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
      if (hasErrors == false) {
        SnackBars.showNormalSnackbar(context, 'Product edited successfully!!!');
      }
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    productName = widget.product.productName;
    productDescription = widget.product.productDescription;
    category = widget.product.category;
    sellingUnit = widget.product.sellingUnit;
    price = widget.product.price.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 4, 122, 83),
          title: const Text('Edit Product'),
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
                        TextFormField(
                          initialValue: productName,
                          autofocus: false,
                          keyboardType: TextInputType.name,
                          validator: (value) {
                            if (value!.trim().isEmpty) {
                              return 'Field is required.';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            border: border,
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                width: 1.5,
                                color: Colors.black54,
                              ),
                              borderRadius: BorderRadius.circular(
                                10,
                              ),
                            ),
                            errorBorder: errorBorder,
                            focusedBorder: focusedBorder,
                            focusedErrorBorder: focusedErrorBorder,
                            label: const AutoSizeText(
                              'Product Name',
                            ),
                            prefixIcon: const Icon(Icons.agriculture),
                          ),
                          onSaved: (text) {
                            productName = text!;
                          },
                          onChanged: (text) {
                            productName = text;
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          initialValue: productDescription,
                          autofocus: false,
                          keyboardType: TextInputType.name,
                          validator: (value) {
                            if (value!.trim().isEmpty) {
                              return 'Field is required.';
                            } else if (value.trim().length <= 6) {
                              return 'Description is too short.';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            border: border,
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                width: 1.5,
                                color: Colors.black54,
                              ),
                              borderRadius: BorderRadius.circular(
                                10,
                              ),
                            ),
                            errorBorder: errorBorder,
                            focusedBorder: focusedBorder,
                            focusedErrorBorder: focusedErrorBorder,
                            label: const AutoSizeText(
                              'Product Description',
                            ),
                            prefixIcon: const Icon(Icons.description),
                          ),
                          onSaved: (text) {
                            productDescription = text!;
                          },
                          onChanged: (text) {
                            productDescription = text;
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        DropdownButtonFormField(
                          value: category,
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
                          onSaved: (value) {
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
                          value: sellingUnit,
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
                          onSaved: (value) {
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
                        TextFormField(
                          initialValue: price.toString(),
                          autofocus: false,
                          keyboardType: TextInputType.number,
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
                          decoration: InputDecoration(
                            border: border,
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                width: 1.5,
                                color: Colors.black54,
                              ),
                              borderRadius: BorderRadius.circular(
                                10,
                              ),
                            ),
                            errorBorder: errorBorder,
                            focusedBorder: focusedBorder,
                            focusedErrorBorder: focusedErrorBorder,
                            label: const AutoSizeText(
                              'Price',
                            ),
                            prefixIcon: const Icon(Icons.description),
                          ),
                          onSaved: (text) {
                            price = text!;
                          },
                          onChanged: (text) {
                            price = text;
                          },
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
                                    color: Colors.green,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    15,
                                  ),
                                ),
                                child: _selectedImage == null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          15,
                                        ),
                                        child: Image(
                                          fit: BoxFit.cover,
                                          image: NetworkImage(
                                            widget.product.productImageUrl,
                                          ),
                                        ),
                                      )
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
                                      ),
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
                                  'Edit Photo',
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
                        _saveForm(
                          Product(
                            productId: widget.product.productId,
                            productImageUrl: widget.product.productImageUrl,
                            productName: productName,
                            productDescription: productDescription,
                            category: category,
                            sellingUnit: sellingUnit,
                            price: double.parse(price.toString()),
                          ),
                        );
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
                                    'Edit Product',
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
