import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:app_nasa/models/apod_model.dart';
import 'package:app_nasa/services/nasa_api.dart';
import 'package:translator/translator.dart' as translator;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<APOD>> _futureAPODs;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _futureAPODs = NasaApi.fetchMultipleAPODs(count: 20);
  }

  List<APOD> _sortByDate(List<APOD> apods) {
    apods.sort((a, b) {
      final dateA = a.date != null ? _dateFormat.parse(a.date!) : DateTime(0);
      final dateB = b.date != null ? _dateFormat.parse(b.date!) : DateTime(0);
      return dateB.compareTo(dateA);
    });
    return apods;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FOTOGRAFIAS DE LA NASA')),
      body: FutureBuilder<List<APOD>>(
        future: _futureAPODs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay datos disponibles'));
          }

          final apods = _sortByDate(snapshot.data!);

          return ListView.builder(
            itemCount: apods.length,
            itemBuilder: (context, index) {
              final apod = apods[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(apod: apod),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      if (apod.url.isNotEmpty)
                        Image.network(
                          apod.url,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              apod.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Fecha: ${apod.date ?? 'Desconocida'}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class DetailScreen extends StatefulWidget {
  final APOD apod;
  const DetailScreen({super.key, required this.apod});

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  String _translatedText = '';
  bool _isTranslating = false;
  final _translator = translator.GoogleTranslator();

  Future<void> _translateToSpanish() async {
    if (_translatedText.isNotEmpty || _isTranslating) return;

    setState(() => _isTranslating = true);
    try {
      final translation = await _translator.translate(
        widget.apod.explanation,
        from: 'en',
        to: 'es',
      );
      setState(() => _translatedText = translation.text);
    } catch (e) {
      setState(() => _translatedText = 'Error en traducción');
    } finally {
      setState(() => _isTranslating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.apod.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.translate),
            onPressed: _translateToSpanish,
            tooltip: 'Traducir al español',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.apod.url.isNotEmpty) Image.network(widget.apod.url),
            const SizedBox(height: 20),
            Text(
              'Fecha: ${widget.apod.date ?? 'Desconocida'}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            _isTranslating
                ? const Center(child: CircularProgressIndicator())
                : Text(
                  _translatedText.isEmpty
                      ? widget.apod.explanation
                      : _translatedText,
                  style: const TextStyle(fontSize: 16),
                ),
          ],
        ),
      ),
    );
  }
}
