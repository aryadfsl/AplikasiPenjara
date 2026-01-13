import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../service/firebase_service.dart';

class EditNarapidanaPage extends StatefulWidget {
  final UserModel inmate;

  const EditNarapidanaPage({super.key, required this.inmate});

  @override
  State<EditNarapidanaPage> createState() => _EditNarapidanaPageState();
}

class _EditNarapidanaPageState extends State<EditNarapidanaPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _blockController;
  late TextEditingController _cellController;
  late TextEditingController _crimeController;
  late DateTime _sentenceEnd;
  late DateTime _sentenceStart;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.inmate.fullName);
    _emailController = TextEditingController(text: widget.inmate.email);
    _blockController = TextEditingController(text: widget.inmate.block);
    _cellController = TextEditingController(text: widget.inmate.cell);
    _crimeController = TextEditingController(text: widget.inmate.crime);
    _sentenceEnd = widget.inmate.sentenceEnd;
    _sentenceStart = widget.inmate.sentenceStart;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _blockController.dispose();
    _cellController.dispose();
    _crimeController.dispose();
    super.dispose();
  }

  String _generateInmateId() {
    // Generate ID dari kombinasi Blok dan Sel
    final block = _blockController.text.trim().toUpperCase();
    final cell = _cellController.text.trim().padLeft(2, '0');
    return '$block-$cell';
  }

  Future<void> _selectDate(BuildContext context, bool isEndDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isEndDate ? _sentenceEnd : _sentenceStart,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blueGrey[800]!,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isEndDate) {
          _sentenceEnd = picked;
        } else {
          _sentenceStart = picked;
        }
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final firebaseService = Provider.of<FirebaseService>(
        context,
        listen: false,
      );
      final newInmateId = _generateInmateId();

      // Create updated user model
      final updatedUser = UserModel(
        id: widget.inmate.id,
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        role: widget.inmate.role,
        block: _blockController.text.trim().toUpperCase(),
        cell: _cellController.text.trim().padLeft(2, '0'),
        inmateId: newInmateId,
        crime: _crimeController.text.trim(),
        sentenceStart: _sentenceStart,
        sentenceEnd: _sentenceEnd,
        status: widget.inmate.status,
        registrationDate: widget.inmate.registrationDate,
      );

      // Update data
      await firebaseService.updateUser(widget.inmate.id, updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white),
                SizedBox(width: 12),
                Text('Data berhasil diperbarui'),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.green[700],
          ),
        );
        Navigator.pop(context, true); // Return true untuk reload data
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Gagal menyimpan: ${e.toString()}')),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Edit Data Narapidana',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueGrey[800],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info ID Preview
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[800],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.badge_outlined, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ID Narapidana',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _generateInmateId(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Informasi Pribadi Section
              _buildSectionTitle(Icons.person_outline, 'Informasi Pribadi'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _nameController,
                label: 'Nama Lengkap',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama lengkap harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email harus diisi';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Format email tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Blok & Sel Section
              _buildSectionTitle(Icons.home_outlined, 'Blok & Sel'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _blockController,
                      label: 'Blok',
                      icon: Icons.location_city_outlined,
                      textCapitalization: TextCapitalization.characters,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Blok harus diisi';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {}); // Update ID preview
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _cellController,
                      label: 'Nomor Sel',
                      icon: Icons.meeting_room_outlined,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nomor sel harus diisi';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {}); // Update ID preview
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Informasi Kasus Section
              _buildSectionTitle(Icons.gavel_outlined, 'Informasi Kasus'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _crimeController,
                label: 'Jenis Kasus',
                icon: Icons.gavel_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jenis kasus harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildDateField(
                label: 'Tanggal Mulai',
                icon: Icons.calendar_today_outlined,
                date: _sentenceStart,
                onTap: () => _selectDate(context, false),
              ),
              const SizedBox(height: 16),
              _buildDateField(
                label: 'Tanggal Selesai',
                icon: Icons.event_outlined,
                date: _sentenceEnd,
                onTap: () => _selectDate(context, true),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      label: 'Batal',
                      backgroundColor: Colors.grey[200]!,
                      textColor: Colors.grey[700]!,
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      label: _isLoading ? 'Menyimpan...' : 'Simpan',
                      backgroundColor: Colors.green[600]!,
                      textColor: Colors.white,
                      onTap: _isLoading ? () {} : _saveChanges,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blueGrey[800],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueGrey[800]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.blueGrey[800]!, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required IconData icon,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blueGrey[800]),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(date),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.calendar_month, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
