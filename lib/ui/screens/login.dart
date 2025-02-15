import 'package:app/constants/constants.dart';
import 'package:app/exceptions/exceptions.dart';
import 'package:app/mixins/stream_subscriber.dart';
import 'package:app/providers/providers.dart';
import 'package:app/ui/screens/screens.dart';
import 'package:app/ui/widgets/qr_login_button.dart';
import 'package:app/ui/widgets/widgets.dart';
import 'package:app/utils/preferences.dart' as preferences;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with StreamSubscriber {
  final formKey = GlobalKey<FormState>();
  var _authenticating = false;
  var _showPassword = false;
  late final AuthProvider _auth;

  late String _email;
  late String _password;
  late String _host;

  @override
  void initState() {
    super.initState();
    _auth = context.read();

    // Try looking for stored values in local storage
    setState(() {
      _host = 'https://Qirim.azatdev.ru';
      _email = preferences.userEmail ?? '';
    });
  }

  @override
  void dispose() {
    unsubscribeAll();
    super.dispose();
  }

  Future<void> showErrorDialog(BuildContext context, {String? message}) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(
          message ?? 'There was a problem logging in. Please try again.',
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  String standardizeHost(String host) {
    host = host.trim().replaceAll(RegExp(r'/+$'), '');

    if (!host.startsWith("http://") && !host.startsWith("https://")) {
      host = "https://" + host;
    }

    return host;
  }

  void redirectToDataLoadingScreen() {
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushReplacementNamed(DataLoadingScreen.routeName);
  }

  Future<void> attemptLogin() async {
    final form = formKey.currentState!;
    var successful = false;

    if (!form.validate()) return;

    form.save();
    setState(() => _authenticating = true);

    try {
      _host = standardizeHost(_host);
      await _auth.login(host: _host, email: _email, password: _password);
      await _auth.tryGetAuthUser();
      successful = true;
    } on HttpResponseException catch (error) {
      await showErrorDialog(
        context,
        message: error.response.statusCode == 401
            ? 'Invalid email or password.'
            : null,
      );
    } catch (error) {
      await showErrorDialog(context);
    } finally {
      setState(() => _authenticating = false);
    }

    if (successful) {
      preferences.host = _host;
      preferences.userEmail = _email;
      redirectToDataLoadingScreen();
    }
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: ['email'],  // Укажите необходимые scopes
);
Future<void> _signInWithGoogle() async {
  try {
    final GoogleSignInAccount? account = await _googleSignIn.signIn();
    if (account != null) {
      print("User signed in: ${account.displayName}");
      print("Email: ${account.email}");
      print("Photo URL: ${account.photoUrl}");

      // Здесь можно добавить логику для обработки успешной авторизации
      // Например, отправить данные на сервер или сохранить в локальном хранилище
      redirectToDataLoadingScreen();
    }
  } catch (error) {
    print("Error signing in with Google: $error");
    await showErrorDialog(context, message: "Failed to sign in with Google.");
  }
}
  Future<void> attemptLoginWithOtp({
    required String host,
    required String token,
  }) async {
    var successful = false;
    setState(() => _authenticating = true);

    try {
      host = standardizeHost(host);
      await _auth.loginWithOneTimeToken(host: host, token: token);
      await _auth.tryGetAuthUser();
      successful = true;
    } on HttpResponseException catch (error) {
      await showErrorDialog(
        context,
        message:
            error.response.statusCode == 401 ? 'Invalid login token.' : null,
      );
    } catch (error) {
      await showErrorDialog(context);
    } finally {
      setState(() => _authenticating = false);
    }

    if (successful) {
      preferences.host = host;
      redirectToDataLoadingScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    String? requireValue(value) =>
        value == null || value.isEmpty ? 'This field is required' : null;

    return Scaffold(
      body: GradientDecoratedContainer(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.hPadding,
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ...[
                    Image.asset('assets/images/logoNew.png', width: 160),
                    // TextFormField(
                    //   keyboardType: TextInputType.url,
                    //   autocorrect: false,
                    //   onChanged: (value) => _host = value,
                    //   onSaved: (value) => _host = value ?? '',
                    //   decoration: InputDecoration(
                    //     labelText: 'Host',
                    //     hintText: 'https://www.koel.music',
                    //   ),
                    //   controller: TextEditingController(text: _host),
                    //   validator: requireValue,
                    // ),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      onChanged: (value) => _email = value,
                      onSaved: (value) => _email = value ?? '',
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'you@koel.music',
                      ),
                      controller: TextEditingController(text: _email),
                      validator: requireValue,
                    ),
                    TextFormField(
                      obscureText: !_showPassword,
                      keyboardType: TextInputType.visiblePassword,
                      onChanged: (value) => _password = value,
                      onSaved: (value) => _password = value ?? '',
                      decoration: InputDecoration(
                        labelText: 'Parol',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showPassword
                                ? CupertinoIcons.eye_slash_fill
                                : CupertinoIcons.eye_fill,
                          ),
                          onPressed: () {
                            setState(() => _showPassword = !_showPassword);
                          },
                        ),
                      ),
                      validator: requireValue,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        child: _authenticating
                            ? const SpinKitThreeBounce(
                                color: Colors.white,
                                size: 16,
                              )
                            : const Text('Kirmek'),
                        onPressed: _authenticating ? null : attemptLogin,
                      ),
                    ),
                   SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                    
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/logo_google.png',  
                            width: 24,
                            height: 24,
                          ),
                          SizedBox(width: 8),
                          Text('Google ile kirmek'),
                        ],
                      ),
                      onPressed: _authenticating ? null : _signInWithGoogle,
                    ),
                  ),
                    _authenticating
                        ? SizedBox()
                        : QrLoginButton(
                            onResult: ({
                              required String host,
                              required String token,
                            }) {
                              attemptLoginWithOtp(host: host, token: token);
                            },
                          ),
                       
                  ].expand((widget) => [widget, const SizedBox(height: 12)]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
