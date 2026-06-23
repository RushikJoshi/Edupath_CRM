import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final inputPath = 'assets/splash/native_splash_logo.png';
  final outputPath = 'assets/splash/launcher_icon_logo.png';

  final inputBytes = File(inputPath).readAsBytesSync();
  final image = img.decodePng(inputBytes);

  if (image == null) {
    print('Failed to decode image');
    return;
  }

  // We want to add a moderate amount of padding.
  // native_splash_logo_fit.png had too much padding (too small).
  // native_splash_logo.png has no padding (too big).
  // Let's add 15% padding on each side.
  // That means the original image will take up 70% of the new canvas.
  
  final int newWidth = (image.width / 0.70).round();
  final int newHeight = (image.height / 0.70).round();
  
  final int dx = ((newWidth - image.width) / 2).round();
  final int dy = ((newHeight - image.height) / 2).round();

  // Create a new empty image with transparency
  final newImage = img.Image(width: newWidth, height: newHeight, numChannels: 4);
  
  // Fill with transparent background
  // image package uses 0 for transparent by default, but let's be explicit
  img.fill(newImage, color: img.ColorRgba8(0, 0, 0, 0));

  // Draw the original image onto the center of the new canvas
  img.compositeImage(newImage, image, dstX: dx, dstY: dy);

  // Save the result
  File(outputPath).writeAsBytesSync(img.encodePng(newImage));
  print('Successfully created padded icon at \$outputPath');
}
