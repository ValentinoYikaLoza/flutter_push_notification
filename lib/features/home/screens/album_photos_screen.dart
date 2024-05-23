import 'package:flutter/material.dart';

class PhotoAlbumScreen extends StatefulWidget {
  const PhotoAlbumScreen({super.key});

  @override
  PhotoAlbumScreenState createState() => PhotoAlbumScreenState();
}

class PhotoAlbumScreenState extends State<PhotoAlbumScreen> {
  final List<String> _images = [
    'https://picsum.photos/id/10/250/250',
    'https://picsum.photos/id/100/250/250',
    'https://picsum.photos/id/100/250/250',
    'https://picsum.photos/id/1001/250/250',
    'https://picsum.photos/id/1002/250/250',
    'https://picsum.photos/id/1003/250/250',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Fotos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.0,
            ),
            itemCount: _images.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: Image.network(
                  _images[index],
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
