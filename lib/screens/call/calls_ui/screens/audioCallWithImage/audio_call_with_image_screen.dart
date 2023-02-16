import 'package:flutter/material.dart';
import 'package:yourteam/screens/call/calls_ui/size_config.dart';

import 'components/body.dart';

class AudioCallWithImage extends StatelessWidget {
  const AudioCallWithImage({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Body(),
    );
  }
}
