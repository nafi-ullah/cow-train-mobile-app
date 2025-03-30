import 'package:flutter/material.dart';

class ImageViewer extends StatelessWidget {
  final String imageUrl;
  final double height;
  final double borderRadius;

  const ImageViewer({
    required this.imageUrl,
    this.height = 150,
    this.borderRadius = 8,
    Key? key,
  }) : super(key: key);

  void _showFullImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black.withOpacity(0.7), // Semi-transparent background
        insetPadding: EdgeInsets.all(10), // Small padding
        child: Stack(
          children: [
            // Centered Large Image
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imageUrl,
                  width: MediaQuery.of(context).size.width * 0.95, // Fit screen width
                  fit: BoxFit.contain, // Keep aspect ratio
                ),
              ),
            ),
            // Close Button
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFullImage(context), // Show full-screen when clicked
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.network(
          imageUrl,
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
