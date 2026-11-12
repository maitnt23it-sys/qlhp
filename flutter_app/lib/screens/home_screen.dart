import 'dart:async';
import 'package:material_ui/material_ui.dart';
import '../models/giang_vien.dart';
import '../services/api_service.dart';
import '../widgets/avatar.dart';
import 'form_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _search = TextEditingController();
  List<GiangVien> _items = [];
  bool _loading = true;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _msg(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  Future<void> _toLogin() async {
    await ApiService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _items = await ApiService.getAll(q: _search.text.trim());
    } on AuthException {
      return _toLogin();
    } catch (e) {
      _msg(e.toString().replaceFirst('Exception: ', ''));
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _openForm([GiangVien? gv]) async {
    final ok = await Navigator.push<bool>(
        context, MaterialPageRoute(builder: (_) => FormScreen(giangVien: gv)));
    if (ok == true) _load();
  }

  Future<void> _delete(GiangVien gv) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa giảng viên'),
        content: Text('Bạn có chắc muốn xóa "${gv.fullname}" (${gv.idgv})?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Xóa')),
        ],
      ),
    );
    if (yes != true) return;
    try {
      await ApiService.delete(gv.id!);
      _msg('Đã xóa');
      _load();
    } on AuthException {
      _toLogin();
    } catch (e) {
      _msg(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalClass = _items.fold<int>(0, (s, e) => s + e.sumClass);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách giảng viên'),
        actions: [
          IconButton(
              tooltip: 'Tải lại',
              icon: const Icon(Icons.refresh),
              onPressed: _load),
          IconButton(
              tooltip: 'Đăng xuất',
              icon: const Icon(Icons.logout),
              onPressed: _toLogin),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Thêm'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _search,
                  onChanged: (_) {
                    _debounce?.cancel();
                    _debounce = Timer(const Duration(milliseconds: 400), _load);
                  },
                  decoration: InputDecoration(
                    hintText: 'Tìm theo mã GV hoặc họ tên...',
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                    suffixIcon: _search.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _search.clear();
                              _load();
                            }),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(children: [
                  Text('Số giảng viên: ${_items.length}'),
                  const Spacer(),
                  Text('Tổng số lớp: $totalClass'),
                ]),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: _items.isEmpty
                            ? ListView(children: const [
                                SizedBox(height: 120),
                                Center(child: Text('Chưa có giảng viên nào'))
                              ])
                            : ListView.builder(
                                padding: const EdgeInsets.only(bottom: 88),
                                itemCount: _items.length,
                                itemBuilder: (_, i) {
                                  final gv = _items[i];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                    child: ListTile(
                                      leading: Avatar(base64Image: gv.image),
                                      title: Text(gv.fullname,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600)),
                                      subtitle: Text(
                                          'Mã GV: ${gv.idgv}  •  Tổng số lớp: ${gv.sumClass}'),
                                      onTap: () => _openForm(gv),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                              icon: const Icon(Icons.edit),
                                              onPressed: () => _openForm(gv)),
                                          IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.red),
                                              onPressed: () => _delete(gv)),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
