import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  // Điểm bắt đầu của ứng dụng Flutter.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab A5',
      debugShowCheckedModeBanner: false,
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
      home: const LabA5Page(),
    );
  }
}

class Contact {
  // Model lưu thông tin liên hệ. Trong Lab A5, đối tượng này đóng vai trò
  // dữ liệu được truyền từ màn hình 1 sang màn hình 2.
  const Contact({
    required this.fullName,
    required this.phone,
    required this.email,
  });

  final String fullName;
  final String phone;
  final String email;

  Contact copyWith({String? fullName, String? phone, String? email}) {
    // Tạo một Contact mới dựa trên Contact hiện tại, chỉ thay các trường cần sửa.
    // Màn hình 2 dùng hàm này để đổi họ tên rồi trả kết quả về màn hình 1.
    return Contact(
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
    );
  }
}

class LabA5Page extends StatefulWidget {
  const LabA5Page({super.key});

  @override
  State<LabA5Page> createState() => _LabA5PageState();
}

class _LabA5PageState extends State<LabA5Page> {
  static const _schoolUrl = 'https://vhu.edu.vn';

  // MethodChannel là cầu nối từ Flutter sang Android native.
  // Ba nút Gọi/Web/Chia sẻ sẽ gọi qua channel này để Android mở implicit Intent.
  static const _intentChannel = MethodChannel('lab_a5/implicit_intents');

  // Controller dùng để đọc/ghi dữ liệu trong các ô nhập liệu.
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  // FocusNode giúp tự đưa con trỏ về ô đang bị lỗi.
  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _emailFocus = FocusNode();

  String? _nameError;
  String? _phoneError;
  String _returnedText = 'Chưa có dữ liệu trả về';

  @override
  void dispose() {
    // Giải phóng controller/focus để tránh rò rỉ bộ nhớ khi màn hình bị hủy.
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  Contact get _currentContact {
    // Gom dữ liệu người dùng đang nhập thành một đối tượng Contact.
    return Contact(
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
    );
  }

  bool _validateContact({bool requirePhone = false}) {
    // Xóa lỗi cũ trước khi kiểm tra lại dữ liệu mới.
    setState(() {
      _nameError = null;
      _phoneError = null;
    });

    if (_nameController.text.trim().isEmpty) {
      setState(() => _nameError = 'Không được để trống');
      _nameFocus.requestFocus();
      return false;
    }

    if (requirePhone && _phoneController.text.trim().isEmpty) {
      setState(() => _phoneError = 'Không được để trống');
      _phoneFocus.requestFocus();
      return false;
    }

    return true;
  }

  Future<void> _openDetail() async {
    if (!_validateContact()) return;

    // Navigator.push mở màn hình 2. Dòng await ở đây sẽ chờ đến khi màn hình 2
    // pop về, giống ý tưởng "mở Activity và nhận kết quả trả về" trong Android.
    final updatedContact = await Navigator.of(context).push<Contact>(
      MaterialPageRoute(
        builder: (_) =>
            DetailPage(contact: _currentContact, sender: 'A5_Flutter'),
      ),
    );

    if (!mounted) return;

    setState(() {
      if (updatedContact == null) {
        _returnedText = 'Người dùng đã hủy, không có dữ liệu trả về';
      } else {
        _nameController.text = updatedContact.fullName;
        _phoneController.text = updatedContact.phone;
        _emailController.text = updatedContact.email;
        _returnedText = 'Màn hình 2 trả về: ${updatedContact.fullName}';
      }
    });
  }

  Future<void> _callPhone() async {
    if (!_validateContact(requirePhone: true)) return;

    // Gửi yêu cầu sang Android để mở ACTION_DIAL với số điện thoại đã nhập.
    await _invokeImplicitIntent('dial', {
      'phone': _phoneController.text.trim(),
    });
  }

  Future<void> _openSchoolWebsite() async {
    // Gửi yêu cầu sang Android để mở ACTION_VIEW với URL của trường.
    await _invokeImplicitIntent('web', {'url': _schoolUrl});
  }

  Future<void> _shareContact() async {
    if (!_validateContact()) return;

    // Gửi yêu cầu sang Android để mở ACTION_SEND và hiện bảng chọn ứng dụng chia sẻ.
    await _invokeImplicitIntent('share', {
      'subject': 'Thông tin liên hệ',
      'text':
          'Liên hệ: ${_nameController.text.trim()} - ${_phoneController.text.trim()}',
    });
  }

  Future<void> _invokeImplicitIntent(
    String method,
    Map<String, String> arguments,
  ) async {
    try {
      // method là tên hành động native cần gọi: dial, web hoặc share.
      // arguments là dữ liệu gửi kèm, tương tự extras trong Intent.
      await _intentChannel.invokeMethod<void>(method, arguments);
    } on PlatformException {
      // Android native sẽ trả lỗi nếu máy/emulator không có ứng dụng xử lý Intent.
      if (mounted) {
        _showMessage('Máy chưa có ứng dụng phù hợp để mở');
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lab A5 - Danh bạ mini')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Lab A5 - Danh bạ mini',
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Chuyển màn hình và truyền dữ liệu',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            _sectionTitle(context, '1. Thông tin liên hệ'),
            const SizedBox(height: 12),
            TextField(
              key: const Key('nameField'),
              controller: _nameController,
              focusNode: _nameFocus,
              decoration: InputDecoration(
                labelText: 'Họ và tên',
                errorText: _nameError,
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('phoneField'),
              controller: _phoneController,
              focusNode: _phoneFocus,
              decoration: InputDecoration(
                labelText: 'Số điện thoại',
                errorText: _phoneError,
              ),
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('emailField'),
              controller: _emailController,
              focusNode: _emailFocus,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const Key('openDetailButton'),
              onPressed: _openDetail,
              icon: const Icon(Icons.open_in_new),
              label: const Text('Xem chi tiết (mở màn hình 2)'),
            ),
            const SizedBox(height: 12),
            Text(
              _returnedText,
              key: const Key('returnedText'),
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 28),
            _sectionTitle(context, '2. Intent ngầm định'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    key: const Key('callButton'),
                    onPressed: _callPhone,
                    icon: const Icon(Icons.call_outlined),
                    label: const Text('Gọi'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    key: const Key('webButton'),
                    onPressed: _openSchoolWebsite,
                    icon: const Icon(Icons.public),
                    label: const Text('Web trường'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              key: const Key('shareButton'),
              onPressed: _shareContact,
              icon: const Icon(Icons.ios_share_outlined),
              label: const Text('Chia sẻ liên hệ'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium
          ?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class DetailPage extends StatefulWidget {
  const DetailPage({super.key, required this.contact, required this.sender});

  // contact là dữ liệu nhận từ màn hình 1; sender giúp minh họa dữ liệu phụ đi kèm.
  final Contact contact;
  final String sender;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late final TextEditingController _updatedNameController;
  final _updatedNameFocus = FocusNode();
  String? _updatedNameError;

  @override
  void initState() {
    super.initState();

    // Khi màn hình 2 mở ra, ô sửa tên được điền sẵn bằng tên nhận từ màn hình 1.
    _updatedNameController = TextEditingController(
      text: widget.contact.fullName,
    );
  }

  @override
  void dispose() {
    _updatedNameController.dispose();
    _updatedNameFocus.dispose();
    super.dispose();
  }

  void _saveAndReturn() {
    final updatedName = _updatedNameController.text.trim();
    if (updatedName.isEmpty) {
      setState(() => _updatedNameError = 'Không được để trống');
      _updatedNameFocus.requestFocus();
      return;
    }

    // pop(value) đóng màn hình 2 và trả Cotact đã sửa về cho màn hình 1.
    Navigator.of(context).pop(widget.contact.copyWith(fullName: updatedName));
  }

  void _cancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết liên hệ')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Chi tiết liên hệ',
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Họ tên: ${widget.contact.fullName}\n'
              'Điện thoại: ${widget.contact.phone}\n'
              'Email: ${widget.contact.email}',
              key: const Key('detailInfo'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Dữ liệu được gửi từ: ${widget.sender}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            TextField(
              key: const Key('updatedNameField'),
              controller: _updatedNameController,
              focusNode: _updatedNameFocus,
              decoration: InputDecoration(
                labelText: 'Sửa họ tên rồi bấm Lưu',
                errorText: _updatedNameError,
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _saveAndReturn(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    key: const Key('saveBackButton'),
                    onPressed: _saveAndReturn,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Lưu & quay lại'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    key: const Key('cancelButton'),
                    onPressed: _cancel,
                    icon: const Icon(Icons.close),
                    label: const Text('Hủy'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
