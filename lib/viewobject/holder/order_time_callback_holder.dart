class OrderTimeCallBackHolder {
  const OrderTimeCallBackHolder({
    required this.firstOrderTime,
    required this.secondOrderTime,
    this.selectedTimes,
    this.selectedDateTime,
  });
  final String firstOrderTime;
  final String secondOrderTime;
  final String? selectedTimes;
  final String? selectedDateTime;

}