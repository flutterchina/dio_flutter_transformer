# dio_flutter_transformer [![Pub](https://img.shields.io/pub/v/dio_flutter_transformer.svg?style=flat-square)](https://pub.dartlang.org/packages/dio_flutter_transformer)

A [dio](https://github.com/flutterchina/dio) transformer especially for flutter, by which the json decoding will be in background with [compute] function.

## Install

```yaml
dependencies:
  dio_flutter_transformer: ^2.0.0  
```

## Usage

Import the package:

```dart
import 'package:dio/dio.dart';
import 'package:dio_flutter_transformer/dio_flutter_transformer.dart';
```

Then replace dio default transformer: 

```dart

var dio=Dio();
dio.transformer=new FlutterTransformer(); // replace dio default transformer
dio.get(...);
```

