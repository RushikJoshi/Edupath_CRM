import 'package:flutter/material.dart';

import 'package:gtcrm/core/injection.dart';

class MultiBranchCrmApp extends StatelessWidget {
  const MultiBranchCrmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Injection.createApp();
  }
}
