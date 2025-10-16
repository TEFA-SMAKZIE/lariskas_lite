class SettingProfit {
  final String profit;
  final String profitText;

  SettingProfit({
    required this.profit,
    required this.profitText,
  });
}

List<SettingProfit> itemProfit = [
  SettingProfit(
    profit: "omzetModal",
    profitText: 'Profit = Omzet - Modal',
  ),
  SettingProfit(
      profit: "omzetModalPengeluaran",
      profitText: 'Profit = Omzet - Modal - Pengeluaran'),
];
