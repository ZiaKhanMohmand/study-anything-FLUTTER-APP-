import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfService {
  /// Lets user pick a PDF and returns extracted text + file name
  Future<({String text, String fileName})?> pickAndExtractPdf() async {
    try {
      // Using file_picker to select a PDF file
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return null;

      final file = result.files.first;
      if (file.bytes == null) return null;

      final document = PdfDocument(inputBytes: file.bytes!);
      final extractor = PdfTextExtractor(document);
      final text = extractor.extractText();
      document.dispose();

      // Limit text to avoid exceeding token limits
      final trimmedText = text.length > 30000 ? text.substring(0, 30000) : text;

      return (text: trimmedText, fileName: file.name);
    } catch (e) {
      print('Error picking PDF: $e');
      return null;
    }
  }
}
