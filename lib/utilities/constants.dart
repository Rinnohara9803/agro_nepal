import 'package:agro_nepal/utilities/themes.dart';
import 'package:flutter/material.dart';

OutlineInputBorder border = OutlineInputBorder(
  borderSide: const BorderSide(width: 1.5, color: Colors.black54),
  borderRadius: BorderRadius.circular(
    10,
  ),
);

OutlineInputBorder errorBorder = OutlineInputBorder(
  borderSide: const BorderSide(width: 1.5, color: Colors.red),
  borderRadius: BorderRadius.circular(
    10,
  ),
);

OutlineInputBorder focusedBorder = OutlineInputBorder(
  borderSide: BorderSide(width: 1.5, color: ThemeClass.primaryColor),
  borderRadius: BorderRadius.circular(
    10,
  ),
);

OutlineInputBorder focusedErrorBorder = OutlineInputBorder(
  borderSide: BorderSide(width: 1.5, color: ThemeClass.primaryColor),
  borderRadius: BorderRadius.circular(
    10,
  ),
);
