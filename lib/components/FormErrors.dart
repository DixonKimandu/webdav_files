import 'package:flutter/material.dart';
import 'package:files_webdav/utils/sizeConfig.dart';

class FormError extends StatelessWidget {
  const FormError({
    Key? key,
    required this.errors,
  }) : super(key: key);

  final List<String> errors;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
          errors.length, (index) => formErrorText(error: errors[index])),
    );
  }

  Row formErrorText({required String error}) {
    return Row(
      children: [
        Icon(
          Icons.dangerous_outlined,
          size: getProportionateScreenWidth(14),
          color: Colors.red,
        ),
        // Icon(Icons.alert),
        // SvgPicture.asset(
        //   "assets/icons/Error.svg",
        //   height: getProportionateScreenWidth(14),
        //   width: getProportionateScreenWidth(14),
        // ),
        SizedBox(
          width: getProportionateScreenWidth(10),
        ),
        Text(
          error,
          style: const TextStyle(color: Colors.red),
        ),
      ],
    );
  }
}
