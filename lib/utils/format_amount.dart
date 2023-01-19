String formatAmount(int amount) {
  String formattedAmount = amount.toString();
  int length = formattedAmount.length;

  for (int i = length - 3; i > 0; i -= 3) {
    formattedAmount =
        "${formattedAmount.substring(0, i)},${formattedAmount.substring(i)}";
  }

  return "\$$formattedAmount";
}
