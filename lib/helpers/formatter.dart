class PriceFormatter {
  static String format(double price) {
    if (price <= 0) return '0 đ';
    final numString = price.round().toString();
    String result = '';
    int count = 0;
    for (int i = numString.length - 1; i >= 0; i--) {
      result = numString[i] + result;
      count++;
      if (count % 3 == 0 && i != 0) {
        result = '.$result';
      }
    }
    return '$result đ';
  }
}