import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _darkMode = false;

  void _setDarkMode(bool value) {
    setState(() => _darkMode = value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab A6',
      debugShowCheckedModeBanner: false,
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF006C67),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4DB6AC),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: LabA6Page(darkMode: _darkMode, onDarkModeChanged: _setDarkMode),
    );
  }
}

class CourseRegistration {
  const CourseRegistration({
    required this.fullName,
    required this.studentId,
    required this.faculty,
    required this.course,
    required this.program,
    required this.sessions,
    required this.emailNotification,
    required this.priorityMode,
  });

  final String fullName;
  final String studentId;
  final String faculty;
  final String course;
  final String program;
  final List<String> sessions;
  final bool emailNotification;
  final bool priorityMode;

  String get summary {
    return 'Ho ten: $fullName\n'
        'MSSV: $studentId\n'
        'Khoa: $faculty\n'
        'Hoc phan: $course\n'
        'He dao tao: $program\n'
        'Buoi hoc: ${sessions.join(', ')}\n'
        'Nhan thong bao: ${emailNotification ? 'Co' : 'Khong'}\n'
        'Che do uu tien: ${priorityMode ? 'Bat' : 'Tat'}';
  }
}

class LabA6Page extends StatefulWidget {
  const LabA6Page({
    super.key,
    required this.darkMode,
    required this.onDarkModeChanged,
  });

  final bool darkMode;
  final ValueChanged<bool> onDarkModeChanged;

  @override
  State<LabA6Page> createState() => _LabA6PageState();
}

class _LabA6PageState extends State<LabA6Page> {
  static const _studentText = 'Nguyen Duc Quang - MSSV 231A290025';
  static const _faculties = <String, List<String>>{
    'Cong nghe thong tin': [
      'Lap trinh tren cac thiet bi di dong',
      'Co so du lieu',
      'Tri tue nhan tao',
      'Kiem thu phan mem',
    ],
    'Kinh te': ['Marketing can ban', 'Quan tri hoc', 'Ke toan dai cuong'],
    'Ngoai ngu': [
      'Tieng Anh giao tiep',
      'Bien phien dich co ban',
      'Ngu am thuc hanh',
    ],
  };

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _nameFocus = FocusNode();
  final _studentIdFocus = FocusNode();

  late String _selectedFaculty;
  late String _selectedCourse;
  String? _program;
  bool _morning = false;
  bool _afternoon = false;
  bool _evening = false;
  bool _emailNotification = true;
  bool _priorityMode = false;

  @override
  void initState() {
    super.initState();
    _selectedFaculty = _faculties.keys.first;
    _selectedCourse = _coursesForFaculty.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _nameFocus.dispose();
    _studentIdFocus.dispose();
    super.dispose();
  }

  List<String> get _coursesForFaculty => _faculties[_selectedFaculty]!;

  List<String> get _selectedSessions {
    return [if (_morning) 'Sang', if (_afternoon) 'Chieu', if (_evening) 'Toi'];
  }

  int get _sessionCount => _selectedSessions.length;

  void _onFacultyChanged(String? value) {
    if (value == null) return;
    setState(() {
      _selectedFaculty = value;
      _selectedCourse = _coursesForFaculty.first;
    });
  }

  void _updateSession(VoidCallback update) {
    setState(update);
  }

  void _confirm() {
    final formIsValid = _formKey.currentState!.validate();
    if (!formIsValid) {
      if (_nameController.text.trim().isEmpty) {
        _nameFocus.requestFocus();
      } else {
        _studentIdFocus.requestFocus();
      }
      return;
    }

    if (_program == null) {
      _showMessage('Vui long chon he dao tao');
      return;
    }

    if (_selectedSessions.isEmpty) {
      _showMessage('Vui long chon it nhat mot buoi hoc');
      return;
    }

    final registration = CourseRegistration(
      fullName: _nameController.text.trim(),
      studentId: _studentIdController.text.trim(),
      faculty: _selectedFaculty,
      course: _selectedCourse,
      program: _program!,
      sessions: _selectedSessions,
      emailNotification: _emailNotification,
      priorityMode: _priorityMode,
    );

    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => ConfirmPage(registration: registration),
      ),
    );
  }

  void _reset() {
    _formKey.currentState?.reset();
    setState(() {
      _nameController.clear();
      _studentIdController.clear();
      _selectedFaculty = _faculties.keys.first;
      _selectedCourse = _coursesForFaculty.first;
      _program = null;
      _morning = false;
      _afternoon = false;
      _evening = false;
      _emailNotification = true;
      _priorityMode = false;
    });
    _nameFocus.requestFocus();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lab A6 - Dang ky hoc phan')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Lab A6 - Dang ky hoc phan',
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(_studentText),
                const SizedBox(height: 20),
                TextFormField(
                  key: const Key('nameField'),
                  controller: _nameController,
                  focusNode: _nameFocus,
                  decoration: const InputDecoration(labelText: 'Ho va ten'),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Khong duoc de trong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('studentIdField'),
                  controller: _studentIdController,
                  focusNode: _studentIdFocus,
                  decoration: const InputDecoration(
                    labelText: 'Ma so sinh vien (10 chu so)',
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (!RegExp(r'^\d{10}$').hasMatch(text)) {
                      return 'MSSV phai gom dung 10 chu so';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                _sectionTitle('Khoa'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  key: const Key('facultyDropdown'),
                  initialValue: _selectedFaculty,
                  items: _faculties.keys
                      .map(
                        (faculty) => DropdownMenuItem(
                          value: faculty,
                          child: Text(faculty),
                        ),
                      )
                      .toList(),
                  onChanged: _onFacultyChanged,
                ),
                const SizedBox(height: 16),
                _sectionTitle('Hoc phan dang ky'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  key: ValueKey('courseDropdown_$_selectedFaculty'),
                  initialValue: _selectedCourse,
                  items: _coursesForFaculty
                      .map(
                        (course) => DropdownMenuItem(
                          value: course,
                          child: Text(course),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedCourse = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                _sectionTitle('He dao tao'),
                RadioGroup<String>(
                  groupValue: _program,
                  onChanged: (value) => setState(() => _program = value),
                  child: const Column(
                    children: [
                      RadioListTile<String>(
                        key: Key('regularRadio'),
                        value: 'Chinh quy',
                        contentPadding: EdgeInsets.zero,
                        title: Text('Chinh quy'),
                      ),
                      RadioListTile<String>(
                        key: Key('partTimeRadio'),
                        value: 'Vua lam vua hoc',
                        contentPadding: EdgeInsets.zero,
                        title: Text('Vua lam vua hoc'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _sectionTitle('Buoi hoc mong muon'),
                CheckboxListTile(
                  key: const Key('morningCheckbox'),
                  value: _morning,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Sang'),
                  onChanged: (value) =>
                      _updateSession(() => _morning = value ?? false),
                ),
                CheckboxListTile(
                  key: const Key('afternoonCheckbox'),
                  value: _afternoon,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Chieu'),
                  onChanged: (value) =>
                      _updateSession(() => _afternoon = value ?? false),
                ),
                CheckboxListTile(
                  key: const Key('eveningCheckbox'),
                  value: _evening,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Toi'),
                  onChanged: (value) =>
                      _updateSession(() => _evening = value ?? false),
                ),
                Text(
                  'Da chon $_sessionCount buoi hoc',
                  key: const Key('sessionCountText'),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  key: const Key('emailSwitch'),
                  value: _emailNotification,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Nhan thong bao qua email'),
                  onChanged: (value) =>
                      setState(() => _emailNotification = value),
                ),
                SwitchListTile(
                  key: const Key('darkModeSwitch'),
                  value: widget.darkMode,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Che do toi'),
                  onChanged: widget.onDarkModeChanged,
                ),
                const SizedBox(height: 8),
                _sectionTitle('Che do uu tien'),
                const SizedBox(height: 8),
                ToggleButtons(
                  key: const Key('priorityToggle'),
                  isSelected: [!_priorityMode, _priorityMode],
                  onPressed: (index) {
                    setState(() => _priorityMode = index == 1);
                  },
                  borderRadius: BorderRadius.circular(8),
                  constraints: const BoxConstraints(
                    minHeight: 44,
                    minWidth: 120,
                  ),
                  children: const [Text('UU TIEN: TAT'), Text('UU TIEN: BAT')],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        key: const Key('confirmButton'),
                        onPressed: _confirm,
                        icon: const Icon(Icons.check),
                        label: const Text('Xac nhan'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        key: const Key('resetButton'),
                        onPressed: _reset,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Lam lai'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 96),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium
          ?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class ConfirmPage extends StatelessWidget {
  const ConfirmPage({super.key, required this.registration});

  final CourseRegistration registration;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xac nhan dang ky')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Xac nhan dang ky',
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                registration.summary,
                key: const Key('summaryText'),
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(height: 1.45),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                key: const Key('editButton'),
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Quay lai chinh sua'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
