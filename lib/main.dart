import 'package:flutter/material.dart';

// Titik awal aplikasi
void main() => runApp(const BmrApp());

// Widget root aplikasi
class BmrApp extends StatelessWidget {
  const BmrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMR Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
      ),
      home: const BmrPage(),
    );
  }
}

// Halaman utama (StatefulWidget karena hasil perhitungan berubah-ubah)
class BmrPage extends StatefulWidget {
  const BmrPage({super.key});

  @override
  State<BmrPage> createState() => _BmrPageState();
}

class _BmrPageState extends State<BmrPage> {
  // Controller untuk membaca isi TextField
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _gender = 'male'; // pilihan gender: 'male' / 'female'
  double? _bmr; // hasil BMR (null = belum dihitung)

  // Daftar tingkat aktivitas beserta pengali kalorinya
  final List<Map<String, dynamic>> _activities = [
    {'label': 'Sedentary: little or no exercise', 'factor': 1.2},
    {'label': 'Exercise 1-3 times/week', 'factor': 1.375},
    {'label': 'Exercise 4-5 times/week', 'factor': 1.465},
    {'label': 'Daily exercise or intense exercise 3-4 times/week', 'factor': 1.55},
    {'label': 'Intense exercise 6-7 times/week', 'factor': 1.725},
    {'label': 'Very intense exercise daily, or physical job', 'factor': 1.9},
  ];

  // Fungsi menghitung BMR dengan rumus Mifflin-St Jeor
  void _calculate() {
    // Validasi form dulu; jika ada yang salah, hentikan
    if (!_formKey.currentState!.validate()) return;

    final age = double.parse(_ageController.text);
    final height = double.parse(_heightController.text); // cm
    final weight = double.parse(_weightController.text); // kg

    // Rumus dasar: 10*berat + 6.25*tinggi - 5*usia
    double bmr = 10 * weight + 6.25 * height - 5 * age;

    // Pria +5, wanita -161
    bmr += (_gender == 'male') ? 5 : -161;

    setState(() => _bmr = bmr);
  }

  // Fungsi mengosongkan semua input dan hasil
  void _clear() {
    _ageController.clear();
    _heightController.clear();
    _weightController.clear();
    setState(() {
      _gender = 'male';
      _bmr = null;
    });
  }

  // Validator angka: harus diisi, angka, dan dalam rentang tertentu
  String? _validate(String? v, double min, double max) {
    if (v == null || v.isEmpty) return 'Wajib diisi';
    final n = double.tryParse(v);
    if (n == null) return 'Harus berupa angka';
    if (n < min || n > max) return 'Isi antara $min - $max';
    return null;
  }

  @override
  void dispose() {
    // Bersihkan controller agar tidak memory leak
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMR Calculator'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Input usia
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Usia',
                  suffixText: 'tahun',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => _validate(v, 15, 80),
              ),
              const SizedBox(height: 16),

              // Pilihan gender
              const Text('Jenis Kelamin'),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Pria'),
                      value: 'male',
                      groupValue: _gender,
                      onChanged: (v) => setState(() => _gender = v!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Wanita'),
                      value: 'female',
                      groupValue: _gender,
                      onChanged: (v) => setState(() => _gender = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Input tinggi badan
              TextFormField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Tinggi',
                  suffixText: 'cm',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => _validate(v, 50, 250),
              ),
              const SizedBox(height: 16),

              // Input berat badan
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Berat',
                  suffixText: 'kg',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => _validate(v, 20, 300),
              ),
              const SizedBox(height: 20),

              // Tombol Hitung & Hapus
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: _calculate,
                      child: const Text('Hitung'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: _clear,
                    child: const Text('Hapus'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Hasil hanya tampil setelah dihitung
              if (_bmr != null) _buildResult(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget tampilan hasil BMR + tabel kebutuhan kalori harian
  Widget _buildResult() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hasil',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                text: 'BMR = ',
                style: const TextStyle(fontSize: 20),
                children: [
                  TextSpan(
                    text: _bmr!.round().toString(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 28),
                  ),
                  const TextSpan(text: ' kalori/hari'),
                ],
              ),
            ),
            const Divider(height: 24),
            const Text('Kebutuhan kalori harian berdasarkan aktivitas',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            // Tiap baris = BMR x pengali aktivitas
            ..._activities.map(
              (a) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(a['label'])),
                    Text(
                      (_bmr! * a['factor']).round().toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}