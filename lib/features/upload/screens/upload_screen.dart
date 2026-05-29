import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:study_anything/widgets/banner_ad_widget.dart';
import '../../../core/services/pdf_service.dart';

final _uploadStateProvider =
    StateProvider<({bool loading, String? error, String? fileName})>(
      (ref) => (loading: false, error: null, fileName: null),
    );

class UploadScreen extends ConsumerWidget {
  const UploadScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(_uploadStateProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE8E8F5)),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF6C63FF),
                size: 16,
              ),
            ),
          ),
        ),
        title: Text(
          'Upload PDF',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: const Color(0xFF1a1a2e),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select your study material',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1a1a2e),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Upload a PDF chapter or document.\nOur AI will analyze it and generate questions.',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey[500],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              _dropZone(context, ref, state),
              if (state.error != null) ...[
                const SizedBox(height: 14),
                _errorBanner(state.error!),
              ],
              const Spacer(),
              _tipsCard(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: BannerAdWidget(),
      ),
    );
  }

  Widget _dropZone(
    BuildContext context,
    WidgetRef ref,
    ({bool loading, String? error, String? fileName}) state,
  ) {
    final hasFile = state.fileName != null;
    return GestureDetector(
      onTap: state.loading ? null : () => _pickPdf(context, ref),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 210,
        decoration: BoxDecoration(
          color: hasFile ? const Color(0xFFEEEDFE) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasFile
                ? const Color(0xFF6C63FF)
                : const Color(0xFF6C63FF).withOpacity(0.3),
            width: hasFile ? 2 : 1.5,
            style: BorderStyle.solid,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: state.loading
            ? _loadingState()
            : hasFile
            ? _fileSelectedState(state.fileName!)
            : _emptyState(),
      ),
    );
  }

  Widget _emptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: const Color(0xFFEEEDFE),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.cloud_upload_outlined,
            size: 36,
            color: Color(0xFF6C63FF),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Tap to select PDF',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1a1a2e),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'PDF files only',
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[400]),
        ),
      ],
    );
  }

  Widget _fileSelectedState(String fileName) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF).withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.picture_as_pdf_rounded,
            size: 36,
            color: Color(0xFF6C63FF),
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            fileName,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1a1a2e),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tap to change file',
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: const Color(0xFF6C63FF),
          ),
        ),
      ],
    );
  }

  Widget _loadingState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            color: Color(0xFF6C63FF),
            strokeWidth: 3,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Extracting PDF text...',
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _errorBanner(String error) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: Colors.red[400], size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              error,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.red[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tipsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEDFE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                'Tips for best results',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: const Color(0xFF534AB7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _tip('Upload one chapter at a time'),
          _tip('Text-based PDFs work best (not scanned images)'),
          _tip('Max ~30 pages recommended'),
        ],
      ),
    );
  }

  Widget _tip(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.15),
              borderRadius: BorderRadius.circular(5),
            ),
            child: const Icon(Icons.check, size: 10, color: Color(0xFF6C63FF)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF534AB7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickPdf(BuildContext context, WidgetRef ref) async {
    ref.read(_uploadStateProvider.notifier).state = (
      loading: true,
      error: null,
      fileName: null,
    );
    try {
      final result = await PdfService().pickAndExtractPdf();
      if (result == null) {
        ref.read(_uploadStateProvider.notifier).state = (
          loading: false,
          error: null,
          fileName: null,
        );
        return;
      }
      ref.read(_uploadStateProvider.notifier).state = (
        loading: false,
        error: null,
        fileName: result.fileName,
      );
      if (context.mounted) {
        context.push(
          '/mode-select',
          extra: {'pdfText': result.text, 'pdfName': result.fileName},
        );
      }
    } catch (e) {
      ref.read(_uploadStateProvider.notifier).state = (
        loading: false,
        error: 'Failed to read PDF. Try another file.',
        fileName: null,
      );
    }
  }
}
