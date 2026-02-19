// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get themeMode => '主题模式';

  @override
  String get systemMode => '跟随系统';

  @override
  String get lightMode => '浅色模式';

  @override
  String get darkMode => '深色模式';

  @override
  String get createConfig => '创建配置';

  @override
  String get manageConfig => '管理配置';

  @override
  String get noConfigFound => '未发现配置文件';

  @override
  String get settings => '设置';

  @override
  String get appearance => '外观设置';

  @override
  String get language => '语言';

  @override
  String get about => '关于项目';

  @override
  String get projectDescription => '一个用于编辑 Dniel97-segatools 配置的图形界面工具';

  @override
  String get version => '版本';

  @override
  String get githubRepo => 'GitHub 仓库';

  @override
  String get githubSub => '查看源代码或提交 Issue';

  @override
  String get overview => '总览';

  @override
  String get dataManagement => '数据管理';

  @override
  String get configFolder => '配置文件存储位置';

  @override
  String get configFolderDesc => '所有的项目列表和配置记录均保存在 %AppData%/configui 中';

  @override
  String get openFolder => '打开文件夹';
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw() : super('zh_TW');

  @override
  String get themeMode => '主題模式';

  @override
  String get systemMode => '跟隨系統';

  @override
  String get lightMode => '淺色模式';

  @override
  String get darkMode => '深色模式';

  @override
  String get createConfig => '建立配置';

  @override
  String get manageConfig => '管理配置';

  @override
  String get noConfigFound => '未發現設定檔';

  @override
  String get settings => '設定';

  @override
  String get appearance => '外觀設定';

  @override
  String get language => '語言';

  @override
  String get about => '關於專案';

  @override
  String get projectDescription => '一個用於編輯 Dniel97-segatools 配置的圖形介面工具';

  @override
  String get version => '版本';

  @override
  String get githubRepo => 'GitHub 儲存庫';

  @override
  String get githubSub => '查看原始碼或提交 Issue';

  @override
  String get overview => '總覽';

  @override
  String get dataManagement => '數據管理';

  @override
  String get configFolder => '配置檔案存儲位置';

  @override
  String get configFolderDesc => '所有的項目列表和配置記錄均保存在 %AppData%/configui 中';

  @override
  String get openFolder => '打開資料夾';
}
