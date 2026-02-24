import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../shared/project.dart';
import '../shared/database.dart';

class ProjectDialogs {
  static void showCreateDialog({
    required BuildContext context,
    required List<Project> currentProjects,
    required Function(Project) onSuccess,
  }) {
    final nameController = TextEditingController();
    final pathController = TextEditingController();
    String selectedType = 'chusan';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return ContentDialog(
            title: const Text('Create New Config'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InfoLabel(
                  label: 'VARIETY',
                  child: ComboBox<String>(
                    isExpanded: true,
                    value: selectedType,
                    items: const [ComboBoxItem(value: 'chusan', child: Text('Chusan'))],
                    onChanged: (v) => setDialogState(() => selectedType = v!),
                  ),
                ),
                const SizedBox(height: 16),
                InfoLabel(label: 'NAME', child: TextBox(controller: nameController, placeholder: 'e.g init')),
                const SizedBox(height: 16),
                InfoLabel(
                  label: 'PATH',
                  child: Row(
                    children: [
                      Expanded(child: TextBox(controller: pathController, placeholder: 'where segatools.ini exists')),
                      const SizedBox(width: 8),
                      Button(
                        child: const Icon(FluentIcons.folder_search),
                        onPressed: () async {
                          FilePickerResult? result = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['ini'],
                            lockParentWindow: true,
                          );

                          if (result != null && result.files.single.path != null) {
                            final filePath = result.files.single.path!;
                            final fileName = p.basename(filePath);

                            if (fileName.toLowerCase() == 'segatools.ini') {
                              final directoryPath = File(filePath).parent.path;
                              setDialogState(() => pathController.text = directoryPath);
                            } else {
                              displayInfoBar(context, builder: (c, close) => const InfoBar(
                                title: Text('Invalid File'),
                                content: Text('Please select "segatools.ini" specifically.'),
                                severity: InfoBarSeverity.warning,
                              ));
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              Button(child: const Text('Cancel'), onPressed: () => Navigator.pop(context)),
              FilledButton(
                onPressed: () async {
                  if (nameController.text.isEmpty || pathController.text.isEmpty) return;
                  try {
                    final String targetPath = p.join(pathController.text, 'segatools.ini');
                    if (!await File(targetPath).exists()) {
                      final String template = await rootBundle.loadString('assets/chusan.ini');
                      await File(targetPath).writeAsString(template);
                    }
                    final newProject = Project(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameController.text,
                      path: pathController.text,
                      type: selectedType,
                      createdAt: DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
                      sortIndex: currentProjects.length,
                      errState: 0,
                    );
                    onSuccess(newProject);
                    Navigator.pop(context);
                  } catch (_) {}
                },
                child: const Text('Create && Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  static Future<void> confirmDelete({
    required BuildContext context,
    required Project project,
    required Function(bool deleteIni) onConfirm,
  }) async {
    bool deleteIniFile = false;
    final result = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => ContentDialog(
          title: const Text('Confirm Deleting?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sure about deleting "${project.name}" '),
              const SizedBox(height: 16),
              Checkbox(
                checked: deleteIniFile,
                onChanged: (v) => setDialogState(() => deleteIniFile = v ?? false),
                content: const Text('BTW Delete binded segatools.ini'),
              ),
            ],
          ),
          actions: [
            Button(child: const Text('Cancel'), onPressed: () => Navigator.pop(context, 'cancel')),
            FilledButton(
              style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.red)),
              onPressed: () => Navigator.pop(context, 'delete'),
              child: const Text('Confirm Deleting'),
            ),
          ],
        ),
      ),
    );

    if (result == 'delete') {
      onConfirm(deleteIniFile);
    }
  }
}