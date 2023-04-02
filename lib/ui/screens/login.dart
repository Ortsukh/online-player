import 'package:app/constants/constants.dart';
import 'package:app/exceptions/exceptions.dart';
import 'package:app/mixins/stream_subscriber.dart';
import 'package:app/providers/providers.dart';
import 'package:app/ui/screens/data_loading.dart';
import 'package:app/ui/widgets/gradient_decorated_container.dart';
import 'package:app/utils/preferences.dart' as preferences;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with StreamSubscriber {
  var _authenticating = false;
  final formKey = GlobalKey<FormState>();

  var _email;
  var _password;
  var _hostUrl;

  @override
  void initState() {
    super.initState();

    // Try looking for stored values in local storage
    setState(() {
      _hostUrl = preferences.hostUrl ?? '';
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

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    Future<void> attemptLogin() async {
      final form = formKey.currentState!;

      if (!form.validate()) return;

      form.save();
      setState(() => _authenticating = true);

      await auth.login(email: _email, password: _password);
      setState(() => _authenticating = false);

      // Store the email into local storage for easy login next time
      preferences.userEmail = _email;
      await auth.tryGetAuthUser();

      Navigator.of(
        context,
        rootNavigator: true,
      ).pushReplacementNamed(DataLoadingScreen.routeName);
    }

    InputDecoration decoration({String? label, String? hint}) {
      return InputDecoration(
        labelText: label,
        hintText: hint,
      );
    }

    String? requireValue(value) =>
        value == null || value.isEmpty ? 'This field is required' : null;

    Widget hostField = TextFormField(
      keyboardType: TextInputType.url,
      autocorrect: false,
      onSaved: (value) => preferences.hostUrl = value,
      decoration: decoration(
        label: 'Host',
        hint: 'https://www.koel.music',
      ),
      controller: TextEditingController(text: _hostUrl),
      validator: requireValue,
    );

    final emailField = TextFormField(
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      onSaved: (value) => _email = value ?? '',
      decoration: decoration(label: 'Email', hint: 'you@koel.music'),
      controller: TextEditingController(text: _email),
      validator: requireValue,
    );

    final passwordField = TextFormField(
      obscureText: true,
      keyboardType: TextInputType.visiblePassword,
      onSaved: (value) => _password = value ?? '',
      decoration: decoration(label: 'Password'),
      validator: requireValue,
    );

    final submitButton = ElevatedButton(
      child: _authenticating
          ? const SpinKitThreeBounce(color: Colors.white, size: 16)
          : const Text('Log In'),
      onPressed: _authenticating
          ? null
          : () async {
              try {
                await attemptLogin();
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
            },
    );

    return Scaffold(
      body: GradientDecoratedContainer(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.horizontalPadding),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ...[
                    Image.asset('assets/images/logo.png', width: 160),
                    hostField,
                    emailField,
                    passwordField,
                    SizedBox(
                      width: double.infinity,
                      child: submitButton,
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
