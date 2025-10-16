class SettingModel {
  final String settingImage;
  final String settingName;
  final String settingAdjust;
  final String settingPrint;
  final String settingProfit;
  final String settingReceipt;
  final String settingReceiptSize;
  final String settingCashdrawer;
  final String settingPrinterAutoCut;
  final String settingSound;

  SettingModel(
      {required this.settingImage,
      required this.settingName,
      required this.settingAdjust,
      required this.settingReceipt,
      required this.settingPrint,
      required this.settingProfit,
      required this.settingReceiptSize,
      required this.settingCashdrawer,
      required this.settingPrinterAutoCut,
      required this.settingSound});

  factory SettingModel.fromJson(Map<String, dynamic> json) {
    return SettingModel(
      settingImage: json['settingImage'],
      settingName: json['settingName'],
      settingAdjust: json['settingAdjust'],
      settingPrint: json['settingPrint'],
      settingProfit: json['settingProfit'],
      settingReceipt: json['settingReceipt'],
      settingReceiptSize: json['settingReceiptSize'],
      settingCashdrawer: json['settingCashdrawer'],
      settingPrinterAutoCut: json['settingPrinterAutoCut'],
      settingSound: json['settingSound'],
    );
  }
}
