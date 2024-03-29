import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skype/utils/universal_variables.dart';

class ShimmeringLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 50,
      child: Shimmer.fromColors(
        baseColor: UniversalVariables.blackColor,
        highlightColor: Colors.white,
        child: Image.network(
            "https://avatars1.githubusercontent.com/u/863999?s=64&v=4"),
      ),
    );
  }
}
