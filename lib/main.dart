import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:english_words/english_words.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: "Aplikasi",
        theme: ThemeData(
          useMaterial3: true,
          colorScheme:
              ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 54, 26, 157)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  var history = <WordPair>[];

  void toggleFavorit(){
    if(favorites.contains(current)){
      favorites.remove(current);
    } else{
      favorites.add(current);
    }
    notifyListeners();
  }

  void toggleHistory(){
    if(history.contains(current)){
      history.remove(current);
  } else {
    history.add(current);
  }
  notifyListeners();
}
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  var selectedIndex = 0;

  @override

  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex){
      case 0:
        page = const GeneratorPage();
      case 1:
        page = const FavoritePage();
      case 2:
        page = const History();
      default:
        page = const Placeholder();
    }



    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)){
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (value){
          setState((){
            selectedIndex = value;
          });
        },
        selectedIndex: selectedIndex,
        destinations: const [
          NavigationDestination(
              selectedIcon: Icon(Icons.home),
              icon: Icon(Icons.home_outlined),
              label: 'Home'),
          NavigationDestination(
              selectedIcon: Icon(Icons.favorite),
              icon: Icon(Icons.favorite_border_outlined),
              label: 'Favorite'),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            label: 'History'),
        ],
      ),
      body: Container(child: page),
    );
  }
}

class GeneratorPage extends StatelessWidget{
  const GeneratorPage({
    super.key
  });

 @override
  
 Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/tenor.gif"), fit: BoxFit.none)),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Good morning!"),
              const Text("I am demotivated"),
              BigCard(pair: pair),
              // ElevatedButton(
              //   onPressed: () {
              //     appState.getNext();
              //     print("button pressed");
              //   },
              //   child: const Text("Generate"),
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorit(); 

                  ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(
                    content: Text('It is ${appState.current}!!!'),
                  ));
                },
                icon: Icon(icon),
                label: const Text("Favorite"),
                ),
              
              SizedBox(width:12),
              ElevatedButton(
                onPressed:(){
                  appState.getNext();
                  appState.toggleHistory();

                },
                child: const Text("Next"),
              ),
            ],
          ),
        ]),
      ),
    );}
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.primary,
      fontSize: 20,
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.bold,
    );

    return Card(
      color: const Color.fromARGB(255, 220, 233, 255),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          pair.asLowerCase,
          style: style,
        ),
      ),
    );
  }
}

class FavoritePage extends StatelessWidget{
  const FavoritePage({super.key});

  Widget build(BuildContext context){

    var appState = context.watch<MyAppState>();
    return Container(
      child: ListView(
        children: [
          Text("Favorite words: ${appState.favorites.length}"),
          ...appState.favorites.map(
            (wp) => ListTile(
              title: Text(wp.asCamelCase),
            )
          )
        ],
      ),
    );
  }
}

class History extends StatelessWidget {
  const History({Key? key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Text(
                  "History of words (${appState.history.length} words):",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...appState.history.asMap().entries.map(
                  (entry) {
                    int index = entry.key + 1;
                    WordPair wordPair = entry.value;
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text('$index'),
                      ),
                      title: Text(wordPair.asCamelCase),
                      onTap: () {
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.amber[200],
                              content: Text(
                                'its word: ${wordPair.asCamelCase}!',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
    // return MaterialApp(
    //   title: 'Flutter Demo',
    //   theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
  //       colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
  //       useMaterial3: true,
  //     ),
  //     home: const MyHomePage(title: 'Flutter Demo Home Page'),
  //   );
  // }
//}

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.

//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;

//   void _incrementCounter() {
//     setState(() {
//       // This call to setState tells the Flutter framework that something has
//       // changed in this State, which causes it to rerun the build method below
//       // so that the display can reflect the updated values. If we changed
//       // _counter without calling setState(), then the build method would not be
//       // called again, and so nothing would appear to happen.
//       _counter++;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       appBar: AppBar(
//         // TRY THIS: Try changing the color here to a specific color (to
//         // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
//         // change color while the other colors stay the same.
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text(widget.title),
//       ),
//       body: Center(
//         // Center is a layout widget. It takes a single child and positions it
//         // in the middle of the parent.
//         child: Column(
//           // Column is also a layout widget. It takes a list of children and
//           // arranges them vertically. By default, it sizes itself to fit its
//           // children horizontally, and tries to be as tall as its parent.
//           //
//           // Column has various properties to control how it sizes itself and
//           // how it positions its children. Here we use mainAxisAlignment to
//           // center the children vertically; the main axis here is the vertical
//           // axis because Columns are vertical (the cross axis would be
//           // horizontal).
//           //
//           // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
//           // action in the IDE, or press "p" in the console), to see the
//           // wireframe for each widget.
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }
