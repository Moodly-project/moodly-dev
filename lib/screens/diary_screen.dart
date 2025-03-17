import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/mood_entry.dart';
import '../utils/app_theme.dart';
import '../utils/storage_service.dart';
import '../widgets/mood_chart.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({Key? key}) : super(key: key);

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> with SingleTickerProviderStateMixin {
  final List<MoodEntry> _entries = [];
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  String _selectedMood = 'Feliz';
  int _moodScore = 4;
  String? _moodFilter;
  bool _isLoading = true;
  late TabController _tabController;
  double _moodSliderValue = 4.0;
  MoodEntry? _entryBeingEdited;
  int? _editingIndex;
  
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
  
  // Mapa invertido para obter o humor a partir da pontuação
  final Map<int, String> _scoreMoods = {
    5: 'Muito Feliz',
    4: 'Feliz',
    3: 'Neutro',
    2: 'Triste',
    1: 'Muito Triste',
  };
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadEntries();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }
  
  Future<void> _loadEntries() async {
    setState(() {
      _isLoading = true;
    });
    
    final loadedEntries = await StorageService.loadMoodEntries();
    
    setState(() {
      _entries.clear();
      _entries.addAll(loadedEntries);
      _isLoading = false;
    });
  }
  
  void _resetFormState() {
    _selectedMood = 'Feliz';
    _moodScore = 4;
    _moodSliderValue = 4.0;
    _noteController.clear();
    _entryBeingEdited = null;
    _editingIndex = null;
  }
  
  Future<void> _addEntry() async {
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
      _resetFormState();
    });
    
    // Salvar entradas no armazenamento local
    await StorageService.saveMoodEntries(_entries);
    
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Entrada adicionada com sucesso!'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }
  
  Future<void> _updateEntry() async {
    if (_noteController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, escreva algo no seu diário')),
      );
      return;
    }
    
    final updatedEntry = MoodEntry(
      date: _entryBeingEdited!.date,
      mood: _selectedMood,
      moodScore: _moodScore,
      note: _noteController.text,
    );
    
    setState(() {
      if (_editingIndex != null) {
        _entries[_editingIndex!] = updatedEntry;
      }
      _resetFormState();
    });
    
    // Salvar entradas no armazenamento local
    await StorageService.saveMoodEntries(_entries);
    
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Entrada atualizada com sucesso!'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }
  
  void _showEntryDialog({MoodEntry? entry, int? index}) {
    // Se entry for fornecido, estamos editando, caso contrário, estamos adicionando
    if (entry != null) {
      _entryBeingEdited = entry;
      _editingIndex = index;
      _selectedMood = entry.mood;
      _moodScore = entry.moodScore;
      _moodSliderValue = entry.moodScore.toDouble();
      _noteController.text = entry.note;
    } else {
      _resetFormState();
    }
    
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
              entry != null ? 'Editar entrada' : 'Como você está se sentindo hoje?',
              style: AppTheme.subheadingStyle,
            ),
            const SizedBox(height: 16),
            
            // Slider para selecionar o humor
            Row(
              children: [
                Icon(
                  Icons.sentiment_very_dissatisfied,
                  color: AppTheme.sadColor,
                  size: 28,
                ),
                Expanded(
                  child: Slider(
                    value: _moodSliderValue,
                    min: 1,
                    max: 5,
                    divisions: 4,
                    activeColor: _getColorForSliderValue(_moodSliderValue),
                    inactiveColor: _getColorForSliderValue(_moodSliderValue).withOpacity(0.3),
                    label: _scoreMoods[_moodSliderValue.round()],
                    onChanged: (value) {
                      setState(() {
                        _moodSliderValue = value;
                        _moodScore = value.round();
                        _selectedMood = _scoreMoods[_moodScore] ?? 'Neutro';
                      });
                    },
                  ),
                ),
                Icon(
                  Icons.sentiment_very_satisfied,
                  color: AppTheme.happyColor,
                  size: 28,
                ),
              ],
            ),
            
            // Texto mostrando o humor selecionado
            Center(
              child: Chip(
                avatar: _buildMoodIcon(_selectedMood),
                label: Text(
                  _selectedMood,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                backgroundColor: _getMoodColor(_selectedMood).withOpacity(0.2),
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
                onPressed: entry != null ? _updateEntry : _addEntry,
                child: Text(entry != null ? 'ATUALIZAR' : 'SALVAR'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrar por humor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ..._moodOptions.map((mood) => 
              RadioListTile<String?>(
                title: Text(mood),
                value: mood,
                groupValue: _moodFilter,
                onChanged: (value) {
                  setState(() {
                    _moodFilter = value;
                  });
                  Navigator.pop(context);
                },
                secondary: _buildMoodIcon(mood),
              ),
            ),
            RadioListTile<String?>(
              title: const Text('Todos'),
              value: null,
              groupValue: _moodFilter,
              onChanged: (value) {
                setState(() {
                  _moodFilter = value;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  List<MoodEntry> get _filteredEntries {
    if (_moodFilter == null) {
      return _entries;
    }
    return _entries.where((entry) => entry.mood == _moodFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Meu Diário de Emoções'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filtrar por humor',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.list), text: 'Registros'),
            Tab(icon: Icon(Icons.insights), text: 'Gráficos'),
            Tab(icon: Icon(Icons.psychology), text: 'Assistente'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Lista de registros
                _entries.isEmpty
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
                    : Column(
                        children: [
                          if (_moodFilter != null)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Chip(
                                label: Text('Filtrando por: $_moodFilter'),
                                deleteIcon: const Icon(Icons.close, size: 18),
                                onDeleted: () {
                                  setState(() {
                                    _moodFilter = null;
                                  });
                                },
                              ),
                            ),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredEntries.length,
                              itemBuilder: (ctx, index) {
                                final entry = _filteredEntries[_filteredEntries.length - 1 - index]; // Mostrar mais recentes primeiro
                                final originalIndex = _entries.indexOf(entry);
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: InkWell(
                                    onTap: () => _showEntryDialog(entry: entry, index: originalIndex),
                                    borderRadius: BorderRadius.circular(12),
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
                                              Row(
                                                children: [
                                                  _buildMoodIcon(entry.mood),
                                                  const SizedBox(width: 8),
                                                  const Icon(
                                                    Icons.edit,
                                                    size: 18,
                                                    color: Colors.grey,
                                                  ),
                                                ],
                                              ),
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
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                
                // Tab 2: Gráficos
                SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      MoodChart(entries: _entries),
                      const SizedBox(height: 16),
                      _buildMoodDistribution(),
                    ],
                  ),
                ),
                
                // Tab 3: Assistente (a ser implementado no futuro)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.psychology,
                        size: 100,
                        color: AppTheme.primaryColor.withOpacity(0.7),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Assistente Moodly',
                        style: AppTheme.headingStyle,
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'Em breve, nosso assistente de IA irá analisar seus padrões emocionais e oferecer insights e recomendações personalizadas.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.notifications),
                        label: const Text('Notificar quando disponível'),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Você será notificado quando o assistente estiver disponível!'),
                              backgroundColor: AppTheme.primaryColor,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEntryDialog(),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildMoodDistribution() {
    // Contando a ocorrência de cada humor
    Map<String, int> moodCounts = {};
    for (final mood in _moodOptions) {
      moodCounts[mood] = 0;
    }
    
    for (final entry in _entries) {
      moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
    }
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Distribuição de Humores',
            style: AppTheme.subheadingStyle,
          ),
          const SizedBox(height: 16),
          ..._moodOptions.map((mood) {
            final count = moodCounts[mood] ?? 0;
            final total = _entries.isEmpty ? 1 : _entries.length;
            final percentage = (count / total * 100).toStringAsFixed(1);
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildMoodIcon(mood),
                      const SizedBox(width: 8),
                      Text(
                        mood,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text('$count (${count > 0 ? percentage : 0}%)'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: count / (total > 0 ? total : 1),
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(_getMoodColor(mood)),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
  
  Color _getMoodColor(String mood) {
    switch (mood) {
      case 'Muito Feliz':
      case 'Feliz':
        return AppTheme.happyColor;
      case 'Neutro':
        return AppTheme.calmColor;
      case 'Triste':
      case 'Muito Triste':
        return AppTheme.sadColor;
      default:
        return AppTheme.primaryColor;
    }
  }
  
  Color _getColorForSliderValue(double value) {
    if (value >= 4.5) return AppTheme.happyColor;
    if (value >= 3.5) return AppTheme.happyColor;
    if (value >= 2.5) return AppTheme.calmColor;
    if (value >= 1.5) return AppTheme.sadColor;
    return AppTheme.sadColor;
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