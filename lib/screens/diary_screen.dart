import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/mood_entry.dart';
import '../models/api_config.dart';
import '../utils/app_theme.dart';
import '../utils/storage_service.dart';
import '../utils/api_service.dart';
import '../widgets/mood_chart.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> with SingleTickerProviderStateMixin {
  final List<MoodEntry> _entries = [];
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _apiUrlController = TextEditingController();
  String _selectedMood = 'Feliz';
  int _moodScore = 4;
  String _selectedProvider = 'openai';
  String? _moodFilter;
  bool _isLoading = true;
  bool _analyzePatterns = true;
  bool _provideSuggestions = true;
  bool _enableReminders = false;
  bool _isApiConfigured = false;
  late TabController _tabController;
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
    _loadApiConfig();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _noteController.dispose();
    _apiKeyController.dispose();
    _apiUrlController.dispose();
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
  
  Future<void> _loadApiConfig() async {
    final apiConfig = await ApiService.loadApiConfig();
    if (apiConfig != null) {
      setState(() {
        _selectedProvider = apiConfig.provider;
        _apiKeyController.text = apiConfig.apiKey;
        _apiUrlController.text = apiConfig.apiUrl ?? '';
        _analyzePatterns = apiConfig.analyzePatterns;
        _provideSuggestions = apiConfig.provideSuggestions;
        _enableReminders = apiConfig.enableReminders;
        _isApiConfigured = true;
      });
    }
  }
  
  Future<void> _saveApiConfig() async {
    if (_apiKeyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, insira uma chave de API válida'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final apiConfig = ApiConfig(
      provider: _selectedProvider,
      apiKey: _apiKeyController.text,
      apiUrl: _apiUrlController.text.isNotEmpty ? _apiUrlController.text : null,
      analyzePatterns: _analyzePatterns,
      provideSuggestions: _provideSuggestions,
      enableReminders: _enableReminders,
    );
    
    final success = await ApiService.saveApiConfig(apiConfig);
    
    if (success) {
      setState(() {
        _isApiConfigured = true;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configurações salvas com sucesso!'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao salvar configurações'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> _clearApiConfig() async {
    final success = await ApiService.clearApiConfig();
    
    if (success) {
      setState(() {
        _selectedProvider = 'openai';
        _apiKeyController.clear();
        _apiUrlController.clear();
        _analyzePatterns = true;
        _provideSuggestions = true;
        _enableReminders = false;
        _isApiConfigured = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configurações removidas com sucesso'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
    }
  }
  
  void _resetFormState() {
    _selectedMood = 'Feliz';
    _moodScore = 4;
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
  
  Future<void> _deleteEntry() async {
    if (_editingIndex != null) {
      setState(() {
        _entries.removeAt(_editingIndex!);
        _resetFormState();
      });
      
      // Salvar entradas no armazenamento local
      await StorageService.saveMoodEntries(_entries);
      
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Entrada excluída com sucesso!'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
  
  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Excluir entrada'),
          content: const Text('Tem certeza que deseja excluir esta entrada? Esta ação não pode ser desfeita.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCELAR'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteEntry();
              },
              child: const Text('EXCLUIR', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
  
  void _showEntryDialog({MoodEntry? entry, int? index}) {
    // Se entry for fornecido, estamos editando, caso contrário, estamos adicionando
    if (entry != null) {
      _entryBeingEdited = entry;
      _editingIndex = index;
      _selectedMood = entry.mood;
      _moodScore = entry.moodScore;
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
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry != null ? 'Editar entrada' : 'Como você está se sentindo hoje?',
                      style: AppTheme.subheadingStyle,
                    ),
                    if (entry != null)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: _showDeleteConfirmationDialog,
                        tooltip: 'Excluir entrada',
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Dropdown para selecionar o humor
                DropdownButtonFormField<String>(
                  value: _selectedMood,
                  decoration: const InputDecoration(
                    labelText: 'Humor',
                    prefixIcon: Icon(Icons.mood),
                  ),
                  items: _moodOptions
                      .map((mood) => DropdownMenuItem(
                            value: mood,
                            child: Row(
                              children: [
                                _buildMoodIcon(mood),
                                const SizedBox(width: 12),
                                Text(mood),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setModalState(() {
                        _selectedMood = value;
                        _moodScore = _moodScores[value] ?? 3;
                      });
                    }
                  },
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
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (entry != null)
                      TextButton.icon(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text('EXCLUIR', style: TextStyle(color: Colors.red)),
                        onPressed: _showDeleteConfirmationDialog,
                      ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: entry != null ? _updateEntry : _addEntry,
                      child: Text(entry != null ? 'ATUALIZAR' : 'SALVAR'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
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
                
                // Tab 3: Assistente (configurações de IA)
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Center(
                          child: Icon(
                            Icons.psychology,
                            size: 80,
                            color: AppTheme.primaryColor.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Text(
                            'Assistente Moodly',
                            style: AppTheme.headingStyle,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'Configure seu assistente de IA para receber insights personalizados baseados em seus padrões emocionais.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Configuração da API',
                                      style: AppTheme.subheadingStyle,
                                    ),
                                    if (_isApiConfigured)
                                      TextButton.icon(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        label: const Text('Limpar', style: TextStyle(color: Colors.red)),
                                        onPressed: _clearApiConfig,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                DropdownButtonFormField<String>(
                                  value: _selectedProvider,
                                  decoration: const InputDecoration(
                                    labelText: 'Provedor de IA',
                                    prefixIcon: Icon(Icons.api),
                                    hintText: 'Selecione o provedor',
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'openai',
                                      child: Text('OpenAI (ChatGPT)'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'anthropic',
                                      child: Text('Anthropic (Claude)'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'google',
                                      child: Text('Google (Gemini)'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'mistral',
                                      child: Text('Mistral AI'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'outro',
                                      child: Text('Outro'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedProvider = value;
                                      });
                                    }
                                  },
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: _apiKeyController,
                                  decoration: const InputDecoration(
                                    labelText: 'Chave da API',
                                    prefixIcon: Icon(Icons.key),
                                    hintText: 'Cole sua chave da API aqui',
                                    helperText: 'A chave será armazenada de forma segura no dispositivo',
                                  ),
                                  obscureText: true,
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: _apiUrlController,
                                  decoration: const InputDecoration(
                                    labelText: 'URL da API (opcional)',
                                    prefixIcon: Icon(Icons.link),
                                    hintText: 'Para provedores personalizados',
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Center(
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.save),
                                    label: const Text('Salvar Configurações'),
                                    onPressed: _saveApiConfig,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Funcionalidades do Assistente',
                                  style: AppTheme.subheadingStyle,
                                ),
                                const SizedBox(height: 15),
                                SwitchListTile(
                                  title: const Text('Análise de Padrões Emocionais'),
                                  subtitle: const Text('Receba insights sobre suas tendências emocionais'),
                                  value: _analyzePatterns,
                                  onChanged: (bool value) {
                                    setState(() {
                                      _analyzePatterns = value;
                                    });
                                  },
                                ),
                                const Divider(),
                                SwitchListTile(
                                  title: const Text('Sugestões de Bem-estar'),
                                  subtitle: const Text('Receba dicas personalizadas baseadas em seu humor'),
                                  value: _provideSuggestions,
                                  onChanged: (bool value) {
                                    setState(() {
                                      _provideSuggestions = value;
                                    });
                                  },
                                ),
                                const Divider(),
                                SwitchListTile(
                                  title: const Text('Lembretes Diários'),
                                  subtitle: const Text('Receba lembretes para registrar suas emoções'),
                                  value: _enableReminders,
                                  onChanged: (bool value) {
                                    setState(() {
                                      _enableReminders = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_isApiConfigured && _entries.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 30.0),
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Insights de IA',
                                    style: AppTheme.subheadingStyle,
                                  ),
                                  const SizedBox(height: 15),
                                  const Text(
                                    'Análise simulada: Seus registros mostram uma tendência de melhora no humor nos últimos dias. Momentos de tristeza ocorrem principalmente pela manhã. Considere praticar atividades ao ar livre nos horários em que seu humor costuma estar mais baixo.',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    'Recomendações:',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 10),
                                  ...[
                                    'Pratique 5 minutos de meditação pela manhã',
                                    'Tente manter um horário regular para dormir',
                                    'Considere caminhar ao ar livre após o almoço',
                                  ].map((tip) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.check_circle, color: AppTheme.primaryColor, size: 20),
                                        const SizedBox(width: 8),
                                        Expanded(child: Text(tip)),
                                      ],
                                    ),
                                  )).toList(),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Center(
                          child: TextButton.icon(
                            icon: const Icon(Icons.help_outline),
                            label: const Text('Como funciona o assistente?'),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Sobre o Assistente'),
                                    content: const SingleChildScrollView(
                                      child: Text(
                                        'O Assistente Moodly utiliza inteligência artificial para analisar seus registros de humor e oferecer insights personalizados.\n\n'
                                        'Para utilizar o assistente, você precisa fornecer uma chave de API válida de um dos provedores suportados.\n\n'
                                        'Suas informações são processadas de forma segura e privada. Nenhum dado pessoal é compartilhado com terceiros.\n\n'
                                        'As análises podem incluir padrões de humor ao longo do tempo, fatores que influenciam seu bem-estar emocional e sugestões para melhorar sua saúde mental.',
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: const Text('Entendi'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
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