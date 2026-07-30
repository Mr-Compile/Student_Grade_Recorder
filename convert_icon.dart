import 'dart:io';
import 'package:image/image.dart';
import 'package:logging/logging.dart';

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.message}');
  });
  final log = Logger('IconGenerator');
  // Create a 1024x1024 image
  final image = Image(width: 1024, height: 1024);
  
  // Fill with solid purple background
  fill(image, color: ColorRgba8(79, 70, 229, 255));
  
  // Draw white document rectangle in center
  const docX = 272;
  const docY = 160;
  const docW = 480;
  const docH = 640;
  
  for (int y = docY; y < docY + docH; y++) {
    for (int x = docX; x < docX + docW; x++) {
      image.setPixelRgba(x, y, 255, 255, 255, 243);
    }
  }
  
  // Draw "A+" text area (purple rectangle)
  const textX = 400;
  const textY = 300;
  const textW = 224;
  const textH = 80;
  
  for (int y = textY; y < textY + textH; y++) {
    for (int x = textX; x < textX + textW; x++) {
      image.setPixelRgba(x, y, 79, 70, 229, 255);
    }
  }
  
  // Draw circle for student icon (left)
  const circle1X = 400;
  const circle1Y = 590;
  const radius = 48;
  
  for (int y = circle1Y - radius; y <= circle1Y + radius; y++) {
    for (int x = circle1X - radius; x <= circle1X + radius; x++) {
      final dist = ((x - circle1X) * (x - circle1X) + (y - circle1Y) * (y - circle1Y)).toDouble();
      if (dist <= radius * radius) {
        image.setPixelRgba(x, y, 79, 70, 229, 255);
      }
    }
  }
  
  // Draw green checkmark circle (right)
  const circle2X = 624;
  const circle2Y = 590;
  
  for (int y = circle2Y - radius; y <= circle2Y + radius; y++) {
    for (int x = circle2X - radius; x <= circle2X + radius; x++) {
      final dist = ((x - circle2X) * (x - circle2X) + (y - circle2Y) * (y - circle2Y)).toDouble();
      if (dist <= radius * radius) {
        image.setPixelRgba(x, y, 16, 185, 129, 255);
      }
    }
  }
  
  // Save the image
  final file = File('assets/launcher_icon.png');
  file.parent.createSync(recursive: true);
  final png = encodePng(image);
  file.writeAsBytesSync(png);
  
  log.info('Icon created successfully at assets/launcher_icon.png');
}
