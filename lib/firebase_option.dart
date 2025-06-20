import 'dart:io';

import 'package:firebase_core/firebase_core.dart';

FirebaseOptions firebaseOptions = Platform.isAndroid ?const FirebaseOptions(
    apiKey: "AIzaSyDAMKrNS9_QpGr6BE2dn6i6x2KeFsZ47IA",
    appId: "1:1089533313864:android:3dcf4ec0a52d39c64ca97d",
    messagingSenderId: "1089533313864",
    projectId: "expensetrackapp-edec8")
    :const FirebaseOptions(
    apiKey: "AIzaSyCK2KhlRZ1qZ4KOc27mOZK21ivCz363kU4",
    appId: "1:1089533313864:ios:1be29968a532928a4ca97d",
    messagingSenderId: "1089533313864",
    projectId: "expensetrackapp-edec8");