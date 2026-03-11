import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/generated/app_localizations.dart';

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ScaffoldPage.scrollable(
      header: PageHeader(title: Text(loc.overview)),
      children: [
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.about,
                style: theme.typography.subtitle?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Image.asset(
                    'assets/app.webp',
                    width: 64,
                    height: 64,
                    fit: BoxFit.contain,
                    errorBuilder: (c, e, s) => const Icon(FluentIcons.app_icon_default, size: 64),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "SEGAIO",
                        style: theme.typography.title?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text("${loc.version} 26.03.10"),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                loc.projectDescription,
                style: theme.typography.body,
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),
              ListTile(
                leading: SvgPicture.asset(
                  'assets/gitea.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(isDark ? Colors.white : Colors.black, BlendMode.srcIn),
                  placeholderBuilder: (c) => const Icon(FluentIcons.link),
                ),
                title: const Text("Gitea"),
                subtitle: const Text("https://gitea.tendokyu.moe/TeamTofuShop/segatools"),
                trailing: const Icon(FluentIcons.open_in_new_window, size: 12),
                onPressed: () => launchUrl(Uri.parse('https://gitea.tendokyu.moe/TeamTofuShop/segatools')),
              ),
              ListTile(
                leading: SvgPicture.asset(
                  'assets/github.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(isDark ? Colors.white : Colors.black, BlendMode.srcIn),
                  placeholderBuilder: (c) => const Icon(FluentIcons.git_graph),
                ),
                title: Text(loc.githubRepo),
                subtitle: Text(loc.githubSub),
                trailing: const Icon(FluentIcons.open_in_new_window, size: 12),
                onPressed: () => launchUrl(Uri.parse('https://github.com/C-F0x/SEGAIO')),
              ),
            ],
          ),
        ),
      ],
    );
  }
}