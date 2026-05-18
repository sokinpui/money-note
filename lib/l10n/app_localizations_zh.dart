// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '记账本';

  @override
  String get dashboard => '仪表盘';

  @override
  String get history => '历史记录';

  @override
  String get settings => '设置';

  @override
  String get addRecord => '添加记录';

  @override
  String get expense => '支出';

  @override
  String get income => '收入';

  @override
  String get name => '名称';

  @override
  String get value => '金额';

  @override
  String get category => '类别';

  @override
  String get note => '备注';

  @override
  String get optional => '可选';

  @override
  String get save => '保存';

  @override
  String get importData => '导入数据';

  @override
  String get exportData => '导出数据';

  @override
  String get appAppearance => '应用外观';

  @override
  String get languagePreference => '语言偏好';

  @override
  String get selectTheme => '选择主题';

  @override
  String get selectLanguage => '选择语言';

  @override
  String get system => '跟随系统';

  @override
  String get light => '浅色模式';

  @override
  String get dark => '深色模式';

  @override
  String get english => '英语';

  @override
  String get chinese => '中文';

  @override
  String get deleteRecord => '删除记录？';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get importSuccess => '导入成功';

  @override
  String get error => '错误';

  @override
  String get close => '关闭';

  @override
  String get exportJson => '导出 JSON';

  @override
  String get importJson => '导入 JSON';

  @override
  String get dailySummary => '每日摘要';

  @override
  String get netEarnings => '净收益';

  @override
  String daysAverage(int days) {
    return '$days天平均';
  }

  @override
  String get type => '类型';

  @override
  String get pleaseFillRequiredFields => '请填写所有必填字段';

  @override
  String get editRecord => '编辑记录';

  @override
  String get unsavedChanges => '未保存的更改';

  @override
  String get unsavedChangesMsg => '您有未保存的更改。确定要离开吗？';

  @override
  String get confirm => '确定';

  @override
  String get multiSelect => '多选';

  @override
  String get newCategory => '新类别';

  @override
  String get categoryName => '类别名称';

  @override
  String get selectIcon => '选择图标';

  @override
  String get other => '其他';
}
