# dio_flutter_transformer [![Pub](https://img.shields.io/pub/v/dio_flutter_transformer.svg?style=flat-square)](https://pub.dartlang.org/packages/dio_flutter_transformer)

A [dio](https://github.com/flutterchina/dio) transformer especially for flutter, by which the json decoding will be in background with [compute] function.

> Through practical experience, we find that although using `compute` can make tasks go on in the background, it may lead to slow task execution. So please think carefully before using it.


## Install

```yaml
dependencies:
  dio_flutter_transformer: ^3.0.2 # latest version
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
dio.transformer = FlutterTransformer(); // replace dio default transformer
dio.get(...);
```

### Options

* `minLength` (default: `0`): When text is under the minimum length, it will not use `compute` to parse.
  * This can be a performance optimization to avoid using a isolate for small texts (which has a static performance overhead).
  * A recommended value to start would be a minimum length of `512`.
* `disableOnWeb` (default: `true`): When set, `compute` will not be used on web, since it it currently not supported.
  * You can set this option to `false` to use `compute` on web.
