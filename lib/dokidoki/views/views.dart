import 'package:flutter/widgets.dart';

getViews(token) {
  return [
    Center(child: Text('Repos Screen. Token: $token')),
    const Center(child: Text('Pulls Screen.')),
    const Center(child: Text('Issues Screen.')),
    const Center(child: Text('Gists Screen.')),
  ];
}