import 'dart:convert';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../models/giang_vien.dart';
import '../services/api_service.dart';
import '../widgets/avatar.dart';

class FormScreen extends StatefulWidget {
  final GiangVien? giangVien; // null = them moi
  const FormScreen({super.key, this.giangVien});
  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _idgv;
  late final TextEditingController _fullname;
  late final TextEditingController _sumClass;
  String _image = '';
  bool _saving = false;

  bool get _isEdit => widget.giangVien != null;

  @override
  void initState() {
    super.initState();
    final g = widget.giangVien;
    _idgv = TextEditingController(text: g?.idgv ?? '');
    _fullname = TextEditingController(text: g?.fullname ?? '');
    _sumClass = TextEditingController(text: g?.sumClass.toString() ?? '');
    _image = g?.image ?? '';
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final file = await ImagePicker()
          .pickImage(source: source, maxWidth: 600, imageQuality: 70);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      setState(() => _image = base64Encode(bytes));
    } catch (e) {
      _msg('Không chọn được ảnh: $e');
    }
  }

  void _showPicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Chọn từ thư viện'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: const Text('Chụp ảnh'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
          ),
          if (_image.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Xóa ảnh'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _image = '');
              },
            ),
        ]),
      ),
    );
  }

  void _msg(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final gv = GiangVien(
      idgv: _idgv.text.trim(),
      fullname: _fullname.text.trim(),
      image: _image,
      sumClass: int.parse(_sumClass.text.trim()),
    );
    try {
      if (_isEdit) {
        await ApiService.update(widget.giangVien!.id!, gv);
      } else {
        await ApiService.create(gv);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      _msg(e.toString().replaceFirst('Exception: ', ''));
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(_isEdit ? 'Sửa giảng viên' : 'Thêm giảng viên')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _showPicker,
                    child: Stack(
                      children: [
                        Avatar(base64Image: _image, radius: 60),
                        const Positioned(
                          right: 0,
                          bottom: 0,
                          child: CircleAvatar(
                              radius: 18, child: Icon(Icons.camera_alt, size: 18)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _idgv,
                  decoration: const InputDecoration(
                      labelText: 'Mã giảng viên (IDGV)',
                      border: OutlineInputBorder()),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Nhập mã giảng viên' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _fullname,
                  decoration: const InputDecoration(
                      labelText: 'Họ và tên (Fullname)',
                      border: OutlineInputBorder()),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Nhập họ và tên' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _sumClass,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                      labelText: 'Tổng số lớp (SumClass)',
                      border: OutlineInputBorder()),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Nhập tổng số lớp' : null,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.save),
                    label: Text(_isEdit ? 'Cập nhật' : 'Lưu'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
