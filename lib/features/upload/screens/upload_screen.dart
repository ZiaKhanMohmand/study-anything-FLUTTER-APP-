import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
      backgroundColor: const Color(0xFFF5F5FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF6C63FF)),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Text(
          'Upload PDF',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D2D2D),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select your study material',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Upload a PDF chapter or document.\nOur AI will analyze it and generate questions.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 40),
              _uploadBox(context, ref, state),
              if (state.error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              _tipsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _uploadBox(
    BuildContext context,
    WidgetRef ref,
    ({bool loading, String? error, String? fileName}) state,
  ) {
    return GestureDetector(
      onTap: state.loading ? null : () => _pickPdf(context, ref),
      child: Container(
        width: double.infinity,
        height: 220,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF6C63FF).withOpacity(0.4),
            width: 2,
            style: BorderStyle.solid,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withOpacity(0.08),
              blurRadius: 20,
            ),
          ],
        ),
        child: state.loading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Color(0xFF6C63FF)),
                  const SizedBox(height: 16),
                  Text(
                    'Extracting PDF text...',
                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    state.fileName != null
                        ? Icons.picture_as_pdf
                        : Icons.cloud_upload_outlined,
                    size: 60,
                    color: const Color(0xFF6C63FF),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    state.fileName ?? 'Tap to select PDF',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2D2D2D),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state.fileName != null
                        ? 'Tap to change file'
                        : 'PDF files only',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _tipsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF6C63FF).withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💡 Tips for best results',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF6C63FF),
            ),
          ),
          const SizedBox(height: 8),
          _tip('Upload one chapter at a time'),
          _tip('Text-based PDFs work best (not scanned images)'),
          _tip('Max ~30 pages recommended'),
        ],
      ),
    );
  }

  Widget _tip(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 14, color: Color(0xFF6C63FF)),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
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
