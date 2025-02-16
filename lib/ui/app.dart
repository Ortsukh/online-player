import 'package:app/constants/constants.dart';
import 'package:app/router.dart';
import 'package:app/ui/screens/screens.dart';
import 'package:app/ui/theme_data.dart';
import 'package:app/ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class MyNavigatorObserver extends NavigatorObserver {
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // Логика при нажатии кнопки "Назад"
    print("Кнопка 'Назад' нажата на экране: ${route.settings.name}");
    super.didPop(route, previousRoute);
  }
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return WillPopScope(
      onWillPop: () async {
        print("onWillPop11");
        // Здесь можно добавить логику, например, показать диалог
        return false; // Возвращает true, чтобы закрыть приложение
      },
      child: Material(
        color: Colors.transparent,
        child: GradientDecoratedContainer(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: AppStrings.appName,
            theme: themeData(context),
            initialRoute: InitialScreen.routeName,
            routes: AppRouter.routes,
            navigatorObservers: [MyNavigatorObserver()],
          ),
        ),
      ),
    );
   
  }
}