import 'package:flutter/material.dart';
import '../models/user.dart';

class AdminInmateDetailPage extends StatelessWidget {
  final UserModel inmate;

  const AdminInmateDetailPage({super.key, required this.inmate});

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _calculateRemainingTime(DateTime endDate) {
    final now = DateTime.now();
    final difference = endDate.difference(now);
    
    if (difference.inDays < 0) {
      return 'Sudah selesai';
    }
    
    final years = difference.inDays ~/ 365;
    final months = (difference.inDays % 365) ~/ 30;
    final days = (difference.inDays % 365) % 30;
    
    List<String> parts = [];
    if (years > 0) parts.add('$years tahun');
    if (months > 0) parts.add('$months bulan');
    if (days > 0 || parts.isEmpty) parts.add('$days hari');
    
    return parts.join(' ');
  }

  Color _getRemainingTimeColor(DateTime endDate) {
    final now = DateTime.now();
    final difference = endDate.difference(now);
    
    if (difference.inDays < 0) return Colors.grey;
    if (difference.inDays < 90) return Colors.orange;
    if (difference.inDays < 180) return Colors.blue;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Detail Narapidana',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueGrey[800],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Profile Card dengan Dark Background
            Container(
              decoration: BoxDecoration(
                color: Colors.blueGrey[800],
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        backgroundColor: Colors.blueGrey[800],
                        radius: 50,
                        child: const Icon(
                          Icons.person_rounded,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      inmate.fullName,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'ID: ${inmate.inmateId}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_getRemainingTimeColor(inmate.sentenceEnd), _getRemainingTimeColor(inmate.sentenceEnd).withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _getRemainingTimeColor(inmate.sentenceEnd).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.timer_outlined, color: Colors.white, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sisa Masa Tahanan',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _calculateRemainingTime(inmate.sentenceEnd),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Informasi Pribadi
            _buildSectionTitle(Icons.person_outline, 'Informasi Pribadi'),
            const SizedBox(height: 12),
            _buildInfoCard([
              _buildModernInfoItem(
                icon: Icons.person_outline,
                label: 'Nama Lengkap',
                value: inmate.fullName,
                iconColor: Colors.blue,
              ),
              _buildModernInfoItem(
                icon: Icons.email_outlined,
                      label: 'Email',
                      value: inmate.email,
                      iconColor: Colors.purple,
                    ),
                    _buildModernInfoItem(
                      icon: Icons.home_outlined,
                      label: 'Blok & Sel',
                      value: '${inmate.block} - ${inmate.cell}',
                      iconColor: Colors.orange,
                      isLast: true,
                    ),
                  ]),
                  const SizedBox(height: 20),

                  // Informasi Kasus
                  _buildSectionTitle(Icons.gavel_outlined, 'Informasi Kasus'),
                  const SizedBox(height: 12),
                  _buildInfoCard([
                    _buildModernInfoItem(
                      icon: Icons.gavel_outlined,
                      label: 'Jenis Kasus',
                      value: inmate.crime,
                      iconColor: Colors.red,
                    ),
                    _buildModernInfoItem(
                      icon: Icons.calendar_today_outlined,
                      label: 'Tanggal Mulai',
                      value: _formatDate(inmate.sentenceStart),
                      iconColor: Colors.green,
                    ),
                    _buildModernInfoItem(
                      icon: Icons.event_outlined,
                      label: 'Tanggal Selesai',
                      value: _formatDate(inmate.sentenceEnd),
                      iconColor: Colors.teal,
                      isLast: true,
                    ),
                  ]),
                  const SizedBox(height: 20),
            // Informasi Registrasi
            _buildSectionTitle(Icons.verified_user_outlined, 'Informasi Registrasi'),
            const SizedBox(height: 12),
            _buildInfoCard([
              _buildModernInfoItem(
                icon: Icons.date_range_outlined,
                label: 'Tanggal Registrasi',
                value: _formatDate(inmate.registrationDate),
                iconColor: Colors.indigo,
              ),
              _buildModernInfoItem(
                icon: Icons.verified_user_outlined,
                label: 'Status',
                value: inmate.role == 'user' ? 'Narapidana' : 'Admin',
                iconColor: Colors.amber,
                isLast: true,
              ),
            ]),
            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.edit_rounded,
                    label: 'Edit Data',
                    backgroundColor: Colors.green[600]!,
                    textColor: Colors.white,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.white),
                              SizedBox(width: 12),
                              Text('Fitur edit sedang dalam pengembangan'),
                            ],
                          ),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.black87,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.delete_rounded,
                    label: 'Hapus',
                    backgroundColor: Colors.red[50]!,
                    textColor: Colors.red[700]!,
                    borderColor: Colors.red[200],
                    onTap: () {
                      _showDeleteDialog(context);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
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
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildModernInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: isLast ? null : Border(
          bottom: BorderSide(color: Colors.grey[100]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: borderColor != null ? Border.all(color: borderColor, width: 1.5) : null,
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: textColor, size: 22),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.warning_rounded, color: Colors.red[700], size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'Hapus Narapidana',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin menghapus data narapidana ini? Tindakan ini tidak dapat dibatalkan.',
          style: TextStyle(fontSize: 15, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.white),
                      SizedBox(width: 12),
                      Text('Fitur delete sedang dalam pengembangan'),
                    ],
                  ),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.red[700],
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Hapus',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}