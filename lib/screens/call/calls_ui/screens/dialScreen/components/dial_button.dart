import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../size_config.dart';

class DialButton extends StatelessWidget {
  const DialButton({
    super.key,
    required this.iconSrc,
    required this.text,
    required this.press,
  });
  final IconData iconSrc;
  final String text;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: SizedBox(
        width: getProportionateScreenWidth(80),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(50)),
            ),
            padding: EdgeInsets.symmetric(
              vertical: getProportionateScreenWidth(20),
            ),
          ),
          onPressed: press,
          child: Column(
            children: [
              if (iconSrc == Icons.speaker)
                SvgPicture.asset(
                  "assets/icons/Icon Volume.svg",
                  color: Colors.white,
                  height: 24,
                ),
              if (iconSrc != Icons.speaker) Icon(iconSrc)
              // const VerticalSpacing(of: 5),
              // Text(
              //   text,
              //   style: const TextStyle(
              //     color: Colors.white,
              //     fontSize: 13,
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
  }
}
