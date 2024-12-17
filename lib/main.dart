import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Joke App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> jokeTypes = [];
  @override
  void initState() {
    super.initState();
    fetchJokeTypes();
  }

  Future<void> fetchJokeTypes() async {
    final response = await http.get(Uri.parse('https://official-joke-api.appspot.com/types'));
    if (response.statusCode == 200) {
      setState(() {
        jokeTypes = List<String>.from(json.decode(response.body));
      });
    } else {
      throw Exception('Failed to load joke types');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Joke Types'),
        actions: [
          IconButton(
            icon: Icon(Icons.shuffle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RandomJokeScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: jokeTypes.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text(jokeTypes[index]),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JokeListScreen(type: jokeTypes[index]),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class JokeListScreen extends StatefulWidget {
  final String type;
  JokeListScreen({required this.type});
  @override
  _JokeListScreenState createState() => _JokeListScreenState();
}

class _JokeListScreenState extends State<JokeListScreen> {
  List<dynamic> jokes = [];
  @override
  void initState() {
    super.initState();
    fetchJokes();
  }

  Future<void> fetchJokes() async {
    final response = await http.get(Uri.parse('https://official-joke-api.appspot.com/jokes/${widget.type}/ten'));
    if (response.statusCode == 200) {
      setState(() {
        jokes = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load jokes');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.type} Jokes'),
      ),
      body: jokes.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: jokes.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text(jokes[index]['setup']),
              subtitle: Text(jokes[index]['punchline']),
            ),
          );
        },
      ),
    );
  }
}

class RandomJokeScreen extends StatefulWidget {
  @override
  _RandomJokeScreenState createState() => _RandomJokeScreenState();
}

class _RandomJokeScreenState extends State<RandomJokeScreen> {
  String setup = '';
  String punchline = '';
  @override
  void initState() {
    super.initState();
    fetchRandomJoke();
  }

  Future<void> fetchRandomJoke() async {
    final response = await http.get(Uri.parse('https://official-joke-api.appspot.com/random_joke'));
    if (response.statusCode == 200) {
      var joke = json.decode(response.body);
      setState(() {
        setup = joke['setup'];
        punchline = joke['punchline'];
      });
    } else {
      throw Exception('Failed to load random joke');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Random Joke of the Day'),
      ),
      body: Center(
        child: setup.isEmpty
            ? CircularProgressIndicator()
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                setup,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                punchline,
                style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


