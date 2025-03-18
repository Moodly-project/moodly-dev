import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/mood_entry.dart';
import '../utils/app_theme.dart';
import '../services/mood_entry_service.dart';
import '../services/activity_service.dart';
import '../services/auth_service.dart';
import '../widgets/mood_chart.dart';
import 'login_screen.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

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
  MoodEntry? _entryBeingEdited;
  int? _editingIndex;
  List<String> _availableActivities = [];
  List<String> _selectedActivities = [];
  
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
    _loadActivities();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }
  
  Future<void> _loadActivities() async {
    try {
      final result = await ActivityService.getAllActivities();
      
      if (result['success']) {
        setState(() {
          _availableActivities = (result['activities'] as List)
              .map((activity) => activity['name'] as String)
              .toList();
        });
      }
    } catch (e) {
      print('Erro ao carregar atividades: $e');
    }
  }
  
  Future<void> _loadEntries() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final result = await MoodEntryService.getMoodEntries();
      
      if (result['success']) {
        setState(() {
          _entries.clear();
          _entries.addAll(result['entries'] as List<MoodEntry>);
          _isLoading = false;
        });
      } else {
        print('Erro ao carregar entradas: ${result['message']}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erro ao carregar entradas: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _resetFormState() {
    _selectedMood = 'Feliz';
    _moodScore = 4;
    _noteController.clear();
    _selectedActivities = [];
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
      activities: _selectedActivities,
    );
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final result = await MoodEntryService.createMoodEntry(newEntry);
      
      setState(() {
        _isLoading = false;
      });
      
      if (result['success']) {
        // Atualizar a lista de entradas
        await _loadEntries();
        
        _resetFormState();
        Navigator.pop(context);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Entrada adicionada com sucesso!'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao adicionar entrada: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> _updateEntry() async {
    if (_noteController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, escreva algo no seu diário')),
      );
      return;
    }
    
    if (_entryBeingEdited == null || _entryBeingEdited!.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro: ID da entrada não encontrado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final updatedEntry = MoodEntry(
      id: _entryBeingEdited!.id,
      date: _entryBeingEdited!.date,
      mood: _selectedMood,
      moodScore: _moodScore,
      note: _noteController.text,
      activities: _selectedActivities,
    );
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final result = await MoodEntryService.updateMoodEntry(
        _entryBeingEdited!.id!,
        updatedEntry,
      );
      
      setState(() {
        _isLoading = false;
      });
      
      if (result['success']) {
        // Atualizar a lista de entradas
        await _loadEntries();
        
        _resetFormState();
        Navigator.pop(context);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Entrada atualizada com sucesso!'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar entrada: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> _deleteEntry(int index) async {
    final entry = _entries[index];
    
    if (entry.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro: ID da entrada não encontrado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final result = await MoodEntryService.deleteMoodEntry(entry.id!);
      
      setState(() {
        _isLoading = false;
      });
      
      if (result['success']) {
        // Remover da lista local
        setState(() {
          _entries.removeAt(index);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Entrada excluída com sucesso!'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir entrada: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _showEntryDialog({MoodEntry? entry, int? index}) {
    _entryBeingEdited = entry;
    _editingIndex = index;
    
    if (entry != null) {
      _selectedMood = entry.mood;
      _moodScore = entry.moodScore;
      _noteController.text = entry.note;
      _selectedActivities = List.from(entry.activities);
    } else {
      _resetFormState();
    }
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(entry == null ? 'Nova Entrada' : 'Editar Entrada'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Como você está se sentindo hoje?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _moodOptions.map((mood) {
                    return ChoiceChip(
                      label: Text(mood),
                      selected: _selectedMood == mood,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedMood = mood;
                            _moodScore = _moodScores[mood]!;
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Atividades realizadas hoje:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _availableActivities.map((activity) {
                    return FilterChip(
                      label: Text(activity),
                      selected: _selectedActivities.contains(activity),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedActivities.add(activity);
                          } else {
                            _selectedActivities.remove(activity);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Anote seus pensamentos:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _noteController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'Escreva aqui seus pensamentos...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (entry == null) {
                  _addEntry();
                } else {
                  _updateEntry();
                }
              },
              child: Text(entry == null ? 'Adicionar' : 'Atualizar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    try {
      await AuthService.logout();
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao fazer logout: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
            onPressed: _logout,
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