import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'dart:async';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baby Monitor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[100],
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 18, color: Colors.black87),
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ),
      home: const MyHomePage(title: 'Baby Monitor'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ApiService apiService = ApiService();
  late Future<Map<String, dynamic>> futureData;
  late Timer _timer;
  Map<String, dynamic>? lastData;

  @override
  void initState() {
    super.initState();
    // Fetch data for the last 10 minutes
    futureData = apiService.fetchData(minutes: 10);

    // Set up a timer to fetch data every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        futureData = apiService.fetchData(minutes: 10);
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        elevation: 4,
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: futureData,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
            lastData = snapshot.data;
          }

          if (snapshot.connectionState == ConnectionState.waiting && lastData == null) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.redAccent,
                    size: 50,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.redAccent, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  if (lastData != null) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Showing last known data:',
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 16),
                    _buildDataWidget(lastData!),
                  ],
                ],
              ),
            );
          } else if (lastData == null && (snapshot.data == null || snapshot.data!.isEmpty)) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blueGrey,
                    size: 50,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No data available',
                    style: TextStyle(color: Colors.blueGrey, fontSize: 18),
                  ),
                ],
              ),
            );
          } else {
            var response = lastData ?? snapshot.data!;
            print('API Response: $response');

            if (response['data'] == null || response['data'].isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blueGrey,
                      size: 50,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No baby status data available',
                      style: TextStyle(color: Colors.blueGrey, fontSize: 18),
                    ),
                  ],
                ),
              );
            }

            var data = response['data'][0];
            return _buildDataWidget(data);
          }
        },
      ),
    );
  }

  Widget _buildDataWidget(Map<String, dynamic> data) {
    String formattedTimestamp = 'N/A';
    if (data['timestamp'] != null) {
      try {
        DateTime utcTime = DateTime.parse(data['timestamp']);
        DateTime bangkokTime = utcTime.add(const Duration(hours: 7));
        formattedTimestamp = DateFormat('dd MMM yyyy, HH:mm:ss').format(bangkokTime);
      } catch (e) {
        print('Error parsing timestamp: $e');
        formattedTimestamp = 'Invalid timestamp';
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Baby Status',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.teal[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Last updated: $formattedTimestamp',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 24),
          _buildDataCard(
            icon: Icons.baby_changing_station,
            title: 'Baby Status',
            value: data['baby_status'] ?? 'N/A',
            color: Colors.pinkAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildDataCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          subtitle: Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}


/*
// this code is work
// update the code every 5s
// update with nice gui
import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Device Monitor',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[100], // Light background for contrast
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: 18, color: Colors.black87),
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ),
      home: DataDisplayScreen(),
    );
  }
}

class DataDisplayScreen extends StatefulWidget {
  @override
  _DataDisplayScreenState createState() => _DataDisplayScreenState();
}

class _DataDisplayScreenState extends State<DataDisplayScreen> {
  final ApiService apiService = ApiService();
  late Future<Map<String, dynamic>> futureData;
  late Timer _timer;
  Map<String, dynamic>? lastData;

  @override
  void initState() {
    super.initState();
    futureData = apiService.fetchData();

    // Set up a timer to fetch data every 5 seconds
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        futureData = apiService.fetchData();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Device Monitor',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal,
        elevation: 4,
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: futureData,
        builder: (context, snapshot) {
          // Update lastData if the snapshot has new data
          if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
            lastData = snapshot.data;
          }

          // Show a loading indicator only if there's no cached data
          if (snapshot.connectionState == ConnectionState.waiting && lastData == null) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.redAccent,
                    size: 50,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(color: Colors.redAccent, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  if (lastData != null) ...[
                    SizedBox(height: 16),
                    Text(
                      'Showing last known data:',
                      style: TextStyle(color: Colors.black54),
                    ),
                    SizedBox(height: 16),
                    _buildDataWidget(lastData!),
                  ],
                ],
              ),
            );
          } else if (lastData == null && (snapshot.data == null || snapshot.data!.isEmpty)) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blueGrey,
                    size: 50,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No data available',
                    style: TextStyle(color: Colors.blueGrey, fontSize: 18),
                  ),
                ],
              ),
            );
          } else {
            var response = lastData ?? snapshot.data!;
            print('API Response: $response');

            if (response['data'] == null || response['data'].isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blueGrey,
                      size: 50,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No sensor data available',
                      style: TextStyle(color: Colors.blueGrey, fontSize: 18),
                    ),
                  ],
                ),
              );
            } 

            var data = response['data'][0];
            return _buildDataWidget(data);
          }
        },
      ),
    );
  }

  Widget _buildDataWidget(Map<String, dynamic> data) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Sensor Readings',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.teal[800],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Last updated: ${data['timestamp'] ?? 'N/A'}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(height: 24),

          // Device Card
          _buildDataCard(
            icon: Icons.devices,
            title: 'Device',
            value: data['device'] ?? 'N/A',
            color: Colors.blueAccent,
          ),

          // Temperature Card
          _buildDataCard(
            icon: Icons.thermostat,
            title: 'Temperature',
            value: data['temperature'] != null ? '${data['temperature']} °C' : 'N/A',
            color: Colors.orangeAccent,
          ),

          // Humidity Card
          _buildDataCard(
            icon: Icons.water_drop,
            title: 'Humidity',
            value: data['humidity'] != null ? '${data['humidity']} %' : 'N/A',
            color: Colors.teal,
          ),
        ],
      ),
    );
  }

  Widget _buildDataCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          subtitle: Text(
            value,
            style: TextStyle(
              fontSize: 18,
              color: Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}
*/

/*
// this code is work
// update the code every 5s
import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DataDisplayScreen(),
    );
  }
}

class DataDisplayScreen extends StatefulWidget {
  @override
  _DataDisplayScreenState createState() => _DataDisplayScreenState();
}

class _DataDisplayScreenState extends State<DataDisplayScreen> {
  final ApiService apiService = ApiService();
  late Future<Map<String, dynamic>> futureData;
  late Timer _timer;
  Map<String, dynamic>? lastData; // Cache the last successful data

  @override
  void initState() {
    super.initState();
    futureData = apiService.fetchData();

    // Set up a timer to fetch data every 5 seconds
    _timer = Timer.periodic(Duration(microseconds: 100), (timer) {
      setState(() {
        futureData = apiService.fetchData();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Smart Home'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: futureData,
        builder: (context, snapshot) {
          // Update lastData if the snapshot has new data
          if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
            lastData = snapshot.data;
          }

          // Show a loading indicator only if there's no cached data
          if (snapshot.connectionState == ConnectionState.waiting && lastData == null) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}'),
                  if (lastData != null) ...[
                    SizedBox(height: 16),
                    Text('Showing last known data:'),
                    _buildDataWidget(lastData!),
                  ],
                ],
              ),
            );
          } else if (lastData == null && (snapshot.data == null || snapshot.data!.isEmpty)) {
            return Center(child: Text('No data available'));
          } else {
            var response = lastData ?? snapshot.data!;
            print('API Response: $response');

            if (response['data'] == null || response['data'].isEmpty) {
              return Center(child: Text('No sensor data available'));
            }

            var data = response['data'][0];
            return _buildDataWidget(data);
          }
        },
      ),
    );
  }

  Widget _buildDataWidget(Map<String, dynamic> data) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Device: ${data['device'] ?? 'N/A'}'),
          Text('Humidity: ${data['humidity'] ?? 'N/A'}'),
          Text('Temperature: ${data['temperature'] ?? 'N/A'}'),
          Text('Timestamp: ${data['timestamp'] ?? 'N/A'}'),
        ],
      ),
    );
  }
}
*/

/*
// this code is work
import 'package:flutter/material.dart';
import 'services/api_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DataDisplayScreen(),
    );
  }
}

class DataDisplayScreen extends StatefulWidget {
  @override
  _DataDisplayScreenState createState() => _DataDisplayScreenState();
}

class _DataDisplayScreenState extends State<DataDisplayScreen> {
  final ApiService apiService = ApiService();
  late Future<Map<String, dynamic>> futureData;

  @override
  void initState() {
    super.initState();
    futureData = apiService.fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Device Data'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          } else {
            var response = snapshot.data!;
            print('API Response: $response'); // Debug the response

            // Check if the 'data' array exists and has at least one item
            if (response['data'] == null || response['data'].isEmpty) {
              return Center(child: Text('No sensor data available'));
            }

            // Access the first item in the 'data' array
            var data = response['data'][0];

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Device: ${data['device'] ?? 'N/A'}'),
                  Text('Humidity: ${data['humidity'] ?? 'N/A'}'),
                  Text('Temperature: ${data['temperature'] ?? 'N/A'}'),
                  Text('Timestamp: ${data['timestamp'] ?? 'N/A'}'),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
*/

/*
import 'package:flutter/material.dart';
import 'services/api_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DataDisplayScreen(),
    );
  }
}

class DataDisplayScreen extends StatefulWidget {
  @override
  _DataDisplayScreenState createState() => _DataDisplayScreenState();
}

class _DataDisplayScreenState extends State<DataDisplayScreen> {
  final ApiService apiService = ApiService();
  late Future<Map<String, dynamic>> futureData;

  @override
  void initState() {
    super.initState();
    futureData = apiService.fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Device Data'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data available'));
          } else {
            var data = snapshot.data!;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Device: ${data['device']}'),
                  Text('Humidity: ${data['humidity']}'),
                  Text('Temperature: ${data['temperature']}'),
                  Text('Timestamp: ${data['timestamp']}'),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
*/


/*
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
*/
