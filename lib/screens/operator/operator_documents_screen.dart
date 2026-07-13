import 'package:flutter/material.dart';
import 'package:aerocrew/constants.dart';
import 'package:aerocrew/screens/operator/operator_pending_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OperatorDocumentsScreen extends StatefulWidget {
  const OperatorDocumentsScreen({super.key});

  @override
  State<OperatorDocumentsScreen> createState() =>
      _OperatorDocumentsScreenState();
}

class _OperatorDocumentsScreenState extends State<OperatorDocumentsScreen> {
  bool isLoading = false;
  Map<String, String> uploadedDocs = {};

  final docs = [
    {
      'id': 'ssm',
      'title': 'SSM Certificate',
      'desc': 'Company registration document',
      'icon': Icons.verified_outlined,
      'required': true,
    },
    {
      'id': 'psv',
      'title': 'PSV Licence',
      'desc': 'Public Service Vehicle licence',
      'icon': Icons.badge_outlined,
      'required': true,
    },
    {
      'id': 'permit',
      'title': 'Operator Permit',
      'desc': 'LPKP operator permit',
      'icon': Icons.article_outlined,
      'required': true,
    },
    {
      'id': 'insurance',
      'title': 'Vehicle Insurance',
      'desc': 'Comprehensive coverage',
      'icon': Icons.security_outlined,
      'required': false,
    },
  ];

  void _simulateUpload(String docId) {
    setState(() {
      uploadedDocs[docId] = 'uploaded';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text('Document uploaded successfully'),
          ],
        ),
        backgroundColor: AeroColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  bool get requiredDocsUploaded {
    final requiredIds = docs
        .where((d) => d['required'] == true)
        .map((d) => d['id'] as String)
        .toList();
    return requiredIds.every((id) => uploadedDocs.containsKey(id));
  }

  Future<void> _submitDocuments() async {
    setState(() => isLoading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'status': 'pending_verification',
        'documentsSubmittedAt': FieldValue.serverTimestamp(),
        'documents': uploadedDocs,
      });
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OperatorPendingScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AeroColors.navy,
      body: Stack(
        children: [
          Positioned(
            bottom: -60,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AeroColors.amber.withValues(alpha: 0.04),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AeroColors.navyCard,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AeroColors.divider,
                              width: 0.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'STEP 2 OF 2',
                            style: TextStyle(
                              fontSize: 11,
                              color: AeroColors.amber,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            'Upload documents',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Verify your\nbusiness.',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Required by PDPA 2010. Stored securely. Reviewed within 24–48 hours.',
                    style: TextStyle(fontSize: 12, color: AeroColors.grey),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AeroColors.background,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          ...docs.map((doc) => _buildDocCard(doc)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AeroColors.navyCard,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AeroColors.divider,
                                width: 0.5,
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.lock_outline,
                                  color: AeroColors.grey,
                                  size: 16,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Documents are encrypted, stored securely, and retained for 7 years per Malaysian commercial law.',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AeroColors.grey,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: !requiredDocsUploaded || isLoading
                                  ? null
                                  : _submitDocuments,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AeroColors.amber,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: AeroColors.amber
                                    .withValues(alpha: 0.3),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      requiredDocsUploaded
                                          ? 'Submit for approval'
                                          : 'Upload required documents first',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocCard(Map<String, dynamic> doc) {
    final docId = doc['id'] as String;
    final isUploaded = uploadedDocs.containsKey(docId);
    final isRequired = doc['required'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AeroColors.cardWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUploaded
              ? AeroColors.success.withValues(alpha: 0.3)
              : AeroColors.cardBorder,
          width: isUploaded ? 1 : 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isUploaded
                  ? AeroColors.successLight
                  : AeroColors.infoLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isUploaded ? Icons.check_circle_outline : doc['icon'] as IconData,
              color: isUploaded ? AeroColors.success : AeroColors.infoText,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      doc['title'] as String,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AeroColors.navy,
                      ),
                    ),
                    if (isRequired) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AeroColors.dangerLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Required',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: AeroColors.danger,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  doc['desc'] as String,
                  style: const TextStyle(fontSize: 11, color: AeroColors.grey),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _simulateUpload(docId),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isUploaded
                    ? AeroColors.successLight
                    : AeroColors.amberLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isUploaded
                      ? AeroColors.success.withValues(alpha: 0.3)
                      : AeroColors.amberBorder,
                ),
              ),
              child: Text(
                isUploaded ? 'Uploaded' : 'Upload',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isUploaded ? AeroColors.success : AeroColors.amber,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
