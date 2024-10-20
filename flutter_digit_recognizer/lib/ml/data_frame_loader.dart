import 'package:flutter/services.dart';
import 'package:ml_dataframe/ml_dataframe.dart';

import '../logger.dart';

class DataFrameLoader {
  static const int _imageWidth = 28;
  static const int _imageSize = 28 * 28;

  DataFrameLoader._();

  static Future<DataFrame> loadTraining() async {
    final List<List<int>> images =
        await _loadImages(path: 'assets/MNIST_ORG/train-images.idx3-ubyte');
    final List<int> labels =
        await _loadLabels(path: 'assets/MNIST_ORG/train-labels.idx1-ubyte');
    _printImageClassification(images[0], labels[0]);
    for (var image in images) {
      image.add(labels[images.indexOf(image)]);
    }
    return DataFrame(images);
  }

  static Future<DataFrame> loadValidation() async {
    final List<List<int>> images =
        await _loadImages(path: 'assets/MNIST_ORG/t10k-images.idx3-ubyte');
    final List<int> labels =
        await _loadLabels(path: 'assets/MNIST_ORG/t10k-labels.idx1-ubyte');
    _printImageClassification(images[0], labels[0]);
    for (var image in images) {
      image.add(labels[images.indexOf(image)]);
    }
    return DataFrame([]);
  }

  static Future<List<List<int>>> _loadImages({required String path}) async {
    ByteData bytes = await rootBundle.load(path);
    final List<List<int>> images = [];
    var nextImage = <int>[];
    // We skip the header data as we know the specifics of the dataset
    // Hence the i = 16
    for (var i = 16; i < bytes.lengthInBytes; i++) {
      nextImage.add(bytes.getUint8(i));
      if (nextImage.length == _imageSize) {
        images.add(nextImage);
        nextImage = <int>[];
      }
    }
    return images;
  }

  static Future<List<int>> _loadLabels({required String path}) async {
    ByteData bytes = await rootBundle.load(path);
    final List<int> labels = [];
    // We skip the header data as we know the specifics of the dataset
    // Hence the i = 8
    for (var i = 8; i < bytes.lengthInBytes; i++) {
      labels.add(bytes.getUint8(i));
    }
    return labels;
  }

  static void _printImageClassification(List<int> image, int label) {
    final StringBuffer print = StringBuffer();
    for (var x = 0; x < _imageWidth; x++) {
      for (var y = 0; y < _imageWidth; y++) {
        print.write(image[x * _imageWidth + y] > 0 ? '█' : ' ');
      }
      print.writeln();
    }
    print.writeln('Label: $label');
    logger.d(print.toString());
  }
}
