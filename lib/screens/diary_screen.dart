import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/mood_entry.dart';
import '../utils/app_theme.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({Key? key}) : super(key: key);

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final List<MoodEntry> _entries = [];
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  String _selectedMood = 'Feliz';
  int _moodScore = 4;
  
  final List<String> _moodOptions = [
    'Muito Feliz',
    'Feliz',
    'Neutro',
    'Triste',
    'Muito Triste'
  ];
  
  final Map<String, int> _moodScores = {
    'Muito Feliz': 5,
    'Feliz': 4,
    'Neutro': 3,
    'Triste': 2,
    'Muito Triste': 1,
  };
  
  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }
  
  void _addEntry() {
    if (_noteController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, escreva algo no seu diário')),
      );
      return;
    }
    
    final newEntry = MoodEntry(
      date: DateTime.now(),
      mood: _selectedMood,
      moodScore: _moodScore,
      note: _noteController.text,
    );
    
    setState(() {
      _entries.add(newEntry);
      _noteController.clear();
    });
    
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Entrada adicionada com sucesso!'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }
  
  void _showAddEntryDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Como você está se sentindo hoje?',
              style: AppTheme.subheadingStyle,
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedMood,
                  isExpanded: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  borderRadius: BorderRadius.circular(10),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedMood = newValue;
                        _moodScore = _moodScores[newValue] ?? 3;
                      });
                    }
                  },
                  items: _moodOptions.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'O que está acontecendo?',
                alignLabelWithHint: true,
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addEntry,
                child: const Text('SALVAR'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Meu Diário de Emoções'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: _entries.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.book,
                    size: 80,
                    color: AppTheme.secondaryColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Seu diário está vazio',
                    style: AppTheme.subheadingStyle,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Adicione sua primeira entrada!',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _entries.length,
              itemBuilder: (ctx, index) {
                final entry = _entries[_entries.length - 1 - index]; // Mostrar mais recentes primeiro
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('dd/MM/yyyy - HH:mm').format(entry.date),
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            _buildMoodIcon(entry.mood),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          entry.note,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEntryDialog,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildMoodIcon(String mood) {
    IconData iconData;
    Color color;
    
    switch (mood) {
      case 'Muito Feliz':
        iconData = Icons.sentiment_very_satisfied;
        color = AppTheme.happyColor;
        break;
      case 'Feliz':
        iconData = Icons.sentiment_satisfied;
        color = AppTheme.happyColor;
        break;
      case 'Neutro':
        iconData = Icons.sentiment_neutral;
        color = AppTheme.calmColor;
        break;
      case 'Triste':
        iconData = Icons.sentiment_dissatisfied;
        color = AppTheme.sadColor;
        break;
      case 'Muito Triste':
        iconData = Icons.sentiment_very_dissatisfied;
        color = AppTheme.sadColor;
        break;
      default:
        iconData = Icons.sentiment_neutral;
        color = AppTheme.calmColor;
    }
    
    return Icon(
      iconData,
      color: color,
      size: 28,
    );
  }
} 