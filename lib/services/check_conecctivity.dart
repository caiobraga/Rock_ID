import 'package:connectivity_plus/connectivity_plus.dart';


class CheckConnectivityService {
  Future<bool> checkIfUserHasConnectivity() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile) {
    print('Connected to a mobile network');
    return true;
  } else if (connectivityResult == ConnectivityResult.wifi) {
    print('Connected to a Wi-Fi network');
    return true;
  } else if (connectivityResult == ConnectivityResult.none) {
    print('No internet connection');
    return false;
  }
  return false;
}
}


