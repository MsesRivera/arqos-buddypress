String getMediaType(String mediaPath) {
  if (mediaPath.toLowerCase().endsWith('.jpg') ||
      mediaPath.toLowerCase().endsWith('.jpeg')) {
    return 'jpeg';
  } else if (mediaPath.toLowerCase().endsWith('.png')) {
    return 'png';
  } else {
    throw ArgumentError('Unsupported media type');
  }
}
