import 'dart:convert';
import 'dart:io';

class SkillInfo {
  final String id;
  final String name;
  final String description;
  final String category;
  final String relativePath; // e.g. "skills/domain/domain-hub/SKILL.md"
  final String htmlRelativePath; // e.g. "skills/domain/domain-hub/domain-hub.html"
  final File markdownFile;
  final String rawContent;
  final List<String> triggers;
  final List<String> referencedSkillIds;

  SkillInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.relativePath,
    required this.htmlRelativePath,
    required this.markdownFile,
    required this.rawContent,
    required this.triggers,
    required this.referencedSkillIds,
  });
}

void main() async {
  final projectDir = Directory.current;
  final agentsDir = Directory('${projectDir.path}/.agents');

  if (!agentsDir.existsSync()) {
    print('Error: .agents directory not found at ${agentsDir.path}');
    exit(1);
  }

  print('🚀 Starting Universal HTML Documentation Generation for .agents ...');

  final skillsDir = Directory('${agentsDir.path}/skills');
  final skillFiles = skillsDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('/SKILL.md') || f.path.endsWith('\\SKILL.md'))
      .toList();

  print('Found ${skillFiles.length} skills.');

  final skills = <String, SkillInfo>{};

  for (final file in skillFiles) {
    final raw = file.readAsStringSync();
    final parsed = parseSkill(file, raw, agentsDir);
    skills[parsed.id] = parsed;
  }

  // Populate cross-referenced skill IDs for all skills
  for (final skill in skills.values) {
    for (final otherId in skills.keys) {
      if (otherId != skill.id &&
          (skill.rawContent.contains(otherId) ||
              skill.rawContent.contains('/$otherId/') ||
              skill.rawContent.contains('/$otherId.md'))) {
        if (!skill.referencedSkillIds.contains(otherId)) {
          skill.referencedSkillIds.add(otherId);
        }
      }
    }
  }

  // 1. Generate individual HTML for each skill
  int generatedCount = 0;
  for (final skill in skills.values) {
    final html = generateSkillHtml(skill, skills);
    final targetHtmlFile = File(
        '${skill.markdownFile.parent.path}/${skill.id}.html');
    targetHtmlFile.writeAsStringSync(html);
    generatedCount++;
  }
  print('✅ Generated $generatedCount individual skill HTML landing pages.');

  // 2. Generate AGENTS.md rules page
  final agentsMdFile = File('${agentsDir.path}/AGENTS.md');
  if (agentsMdFile.existsSync()) {
    final agentsMdContent = agentsMdFile.readAsStringSync();
    final rulesHtml = generateAgentsRulesHtml(agentsMdContent, skills);
    final rulesHtmlFile = File('${agentsDir.path}/agents-rules.html');
    rulesHtmlFile.writeAsStringSync(rulesHtml);
    print('✅ Generated agents-rules.html for AGENTS.md.');
  }

  // 3. Generate Central Hub index.html
  final hubHtml = generateIndexHubHtml(skills.values.toList());
  final hubHtmlFile = File('${agentsDir.path}/index.html');
  hubHtmlFile.writeAsStringSync(hubHtml);
  print('✅ Generated Central Portal at .agents/index.html.');

  print('🎉 All documentation pages generated successfully with full bilingual Ukrainian/English support and hyperlinked cross-references!');
}

SkillInfo parseSkill(File file, String content, Directory agentsDir) {
  final relPath = file.path
      .replaceAll('\\', '/')
      .substring(agentsDir.path.replaceAll('\\', '/').length + 1);

  String name = '';
  String description = '';

  // Extract YAML frontmatter
  if (content.startsWith('---')) {
    final endIdx = content.indexOf('---', 3);
    if (endIdx != -1) {
      final frontmatter = content.substring(3, endIdx);
      final lines = frontmatter.split('\n');
      for (final line in lines) {
        if (line.trim().startsWith('name:')) {
          name = line.replaceFirst(RegExp(r'^\s*name:\s*'), '').trim();
        } else if (line.trim().startsWith('description:')) {
          description = line.replaceFirst(RegExp(r'^\s*description:\s*'), '').trim();
        }
      }
    }
  }

  final dirParts = relPath.split('/');
  final folderName = dirParts[dirParts.length - 2];
  final id = name.isNotEmpty ? name : folderName;

  String category = 'General';
  if (relPath.contains('domain/')) category = 'Domain Layer';
  else if (relPath.contains('data/')) category = 'Data Layer';
  else if (relPath.contains('presentation/state-management/')) category = 'State Management';
  else if (relPath.contains('presentation/navigation/')) category = 'Navigation';
  else if (relPath.contains('presentation/theme/')) category = 'Theme & Styling';
  else if (relPath.contains('presentation/ui-utils/')) category = 'UI Utilities';
  else if (relPath.contains('presentation/ui/ui-kit/')) category = 'UI Kit';
  else if (relPath.contains('presentation/ui/forms/')) category = 'Forms';
  else if (relPath.contains('presentation/ui/')) category = 'UI & Widgets';
  else if (relPath.contains('presentation/')) category = 'Presentation Layer';
  else if (relPath.contains('infrastructure/')) category = 'Infrastructure Layer';
  else if (relPath.contains('testing/')) category = 'Testing';
  else if (relPath.contains('git/')) category = 'Git Workflow';
  else if (relPath.contains('bootstrap/')) category = 'Project Bootstrap';
  else if (relPath.contains('adoption/')) category = 'Project Adoption';
  else if (relPath.contains('error-handling/')) category = 'Error Handling';
  else if (relPath.contains('l10n/')) category = 'Localization (l10n)';
  else if (relPath.contains('core/')) category = 'Core Utilities';
  else if (relPath.contains('native/')) category = 'Native Platforms';
  else if (relPath.contains('documentation/')) category = 'Documentation';
  else if (id.startsWith('dart-')) category = 'Dart Best Practices';
  else if (id.startsWith('flutter-')) category = 'Flutter Architecture';

  final htmlRelPath = relPath.replaceFirst('SKILL.md', '$id.html');

  final triggers = <String>[];
  if (description.isNotEmpty) {
    final words = description.split(RegExp(r'[\s,\(\)\.\:]+'));
    for (final w in words) {
      if (w.length > 3 && !['with', 'from', 'this', 'that', 'using', 'into', 'when', 'then', 'pure', 'only'].contains(w.toLowerCase())) {
        if (!triggers.contains(w.toLowerCase()) && triggers.length < 8) {
          triggers.add(w.toLowerCase());
        }
      }
    }
  }

  return SkillInfo(
    id: id,
    name: name.isNotEmpty ? name : folderName,
    description: description,
    category: category,
    relativePath: relPath,
    htmlRelativePath: htmlRelPath,
    markdownFile: file,
    rawContent: content,
    triggers: triggers,
    referencedSkillIds: [],
  );
}

String getCategoryUa(String category) {
  switch (category) {
    case 'Domain Layer': return 'Шар Domain (Бізнес-логіка)';
    case 'Data Layer': return 'Шар Data (Дані та API)';
    case 'Presentation Layer': return 'Шар Presentation (Інтерфейс)';
    case 'State Management': return 'Керування станом (BLoC)';
    case 'Navigation': return 'Навігація (AutoRoute)';
    case 'Theme & Styling': return 'Теми та Стилі';
    case 'UI Utilities': return 'UI Утиліти та Розширення';
    case 'UI Kit': return 'UI Kit Компоненти';
    case 'Forms': return 'Форми (Reactive Forms)';
    case 'UI & Widgets': return 'UI Віджети та Анімації';
    case 'Infrastructure Layer': return 'Інфраструктура та Сервіси';
    case 'Testing': return 'Тестування (Unit, Widget, BLoC)';
    case 'Git Workflow': return 'Робота з Git';
    case 'Project Bootstrap': return 'Ініціалізація Проєкту';
    case 'Project Adoption': return 'Адаптація Кодової Бази';
    case 'Error Handling': return 'Обробка Помилок';
    case 'Localization (l10n)': return 'Локалізація (l10n)';
    case 'Core Utilities': return 'Core Утиліти та Розширення';
    case 'Native Platforms': return 'Нативні Платформи (iOS/Android)';
    case 'Documentation': return 'Документація';
    case 'Dart Best Practices': return 'Стандарти Dart';
    case 'Flutter Architecture': return 'Архітектура Flutter';
    default: return category;
  }
}

String computeRelativePath(String fromFilePath, String toFilePath) {
  final fromParts = fromFilePath.split('/');
  fromParts.removeLast(); // Remove filename
  final toParts = toFilePath.split('/');

  int common = 0;
  while (common < fromParts.length && common < toParts.length && fromParts[common] == toParts[common]) {
    common++;
  }

  final upSteps = fromParts.length - common;
  final result = <String>[];
  for (int i = 0; i < upSteps; i++) {
    result.add('..');
  }
  for (int i = common; i < toParts.length; i++) {
    result.add(toParts[i]);
  }

  return result.join('/');
}

String escapeHtml(String text) {
  return text
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#039;');
}

String convertMarkdownToHtml(String markdown, SkillInfo currentSkill, Map<String, SkillInfo> allSkills) {
  // Strip YAML frontmatter if present
  String content = markdown;
  if (content.startsWith('---')) {
    final endIdx = content.indexOf('---', 3);
    if (endIdx != -1) {
      content = content.substring(endIdx + 3).trim();
    }
  }

  final lines = content.split('\n');
  final sb = StringBuffer();

  bool inCodeBlock = false;
  String codeBlockLang = '';
  final codeBlockBuffer = StringBuffer();

  bool inMermaid = false;
  final mermaidBuffer = StringBuffer();

  bool inList = false;
  bool inTable = false;

  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];

    // Handle code blocks
    if (line.trim().startsWith('```')) {
      if (!inCodeBlock && !inMermaid) {
        final lang = line.trim().substring(3).trim().toLowerCase();
        if (lang == 'mermaid') {
          inMermaid = true;
          mermaidBuffer.clear();
        } else {
          inCodeBlock = true;
          codeBlockLang = lang;
          codeBlockBuffer.clear();
        }
        continue;
      } else if (inMermaid) {
        inMermaid = false;
        sb.writeln('<div class="mermaid-container"><div class="mermaid">${mermaidBuffer.toString()}</div></div>');
        continue;
      } else if (inCodeBlock) {
        inCodeBlock = false;
        final rawCode = codeBlockBuffer.toString();
        sb.writeln('''
<div class="code-block-wrapper">
  <div class="code-header">
    <span class="code-lang">${codeBlockLang.isNotEmpty ? codeBlockLang : 'text'}</span>
    <button class="copy-btn" onclick="copyCode(this)">
      <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg>
      <span class="btn-text" data-i18n="copy">Copy</span>
    </button>
  </div>
  <pre><code class="language-${codeBlockLang.isNotEmpty ? codeBlockLang : 'plaintext'}">${escapeHtml(rawCode)}</code></pre>
</div>''');
        continue;
      }
    }

    if (inMermaid) {
      mermaidBuffer.writeln(line);
      continue;
    }

    if (inCodeBlock) {
      codeBlockBuffer.writeln(line);
      continue;
    }

    // Check for tables
    if (line.trim().startsWith('|') && line.trim().endsWith('|')) {
      if (!inTable) {
        inTable = true;
        sb.writeln('<div class="table-responsive"><table class="doc-table">');
        // Check if header
        final cells = line.split('|').where((c) => c.isNotEmpty).map((c) => c.trim()).toList();
        sb.writeln('<thead><tr>');
        for (final cell in cells) {
          sb.writeln('<th>${formatInlineMarkdown(cell, currentSkill, allSkills)}</th>');
        }
        sb.writeln('</tr></thead><tbody>');
        continue;
      } else if (line.contains('---')) {
        // Table separator row
        continue;
      } else {
        final cells = line.split('|').where((c) => c.isNotEmpty).map((c) => c.trim()).toList();
        sb.writeln('<tr>');
        for (final cell in cells) {
          sb.writeln('<td>${formatInlineMarkdown(cell, currentSkill, allSkills)}</td>');
        }
        sb.writeln('</tr>');
        continue;
      }
    } else if (inTable) {
      inTable = false;
      sb.writeln('</tbody></table></div>');
    }

    // Check for Headings
    if (line.startsWith('# ')) {
      sb.writeln('<h1 class="doc-h1">${formatInlineMarkdown(line.substring(2), currentSkill, allSkills)}</h1>');
    } else if (line.startsWith('## ')) {
      final text = line.substring(3).trim();
      final id = text.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '-').toLowerCase();
      sb.writeln('<h2 id="$id" class="doc-h2"><a href="#$id" class="heading-anchor">#</a> ${formatInlineMarkdown(text, currentSkill, allSkills)}</h2>');
    } else if (line.startsWith('### ')) {
      final text = line.substring(4).trim();
      sb.writeln('<h3 class="doc-h3">${formatInlineMarkdown(text, currentSkill, allSkills)}</h3>');
    } else if (line.startsWith('#### ')) {
      final text = line.substring(5).trim();
      sb.writeln('<h4 class="doc-h4">${formatInlineMarkdown(text, currentSkill, allSkills)}</h4>');
    } else if (line.trim().startsWith('- [ ] ') || line.trim().startsWith('- [x] ')) {
      final isChecked = line.trim().startsWith('- [x] ');
      final text = line.trim().substring(6);
      sb.writeln('''
<div class="checklist-item">
  <label class="checkbox-container">
    <input type="checkbox" ${isChecked ? 'checked' : ''} onchange="updateChecklistProgress()">
    <span class="checkmark"></span>
    <span class="check-text">${formatInlineMarkdown(text, currentSkill, allSkills)}</span>
  </label>
</div>''');
    } else if (line.trim().startsWith('- ') || line.trim().startsWith('* ')) {
      if (!inList) {
        inList = true;
        sb.writeln('<ul class="doc-list">');
      }
      final text = line.trim().substring(2);
      sb.writeln('<li>${formatInlineMarkdown(text, currentSkill, allSkills)}</li>');
    } else if (RegExp(r'^\d+\.\s').hasMatch(line.trim())) {
      if (!inList) {
        inList = true;
        sb.writeln('<ol class="doc-ordered-list">');
      }
      final text = line.trim().replaceFirst(RegExp(r'^\d+\.\s'), '');
      sb.writeln('<li>${formatInlineMarkdown(text, currentSkill, allSkills)}</li>');
    } else {
      if (inList) {
        inList = false;
        sb.writeln('</ul>');
      }

      if (line.trim().startsWith('> [!NOTE]') || line.trim().startsWith('> [!IMPORTANT]') || line.trim().startsWith('> [!WARNING]') || line.trim().startsWith('> [!TIP]')) {
        String alertType = 'info';
        String alertTitle = 'NOTE';
        if (line.contains('IMPORTANT')) { alertType = 'warning'; alertTitle = 'ВАЖЛИВО / IMPORTANT'; }
        else if (line.contains('WARNING')) { alertType = 'error'; alertTitle = 'УВАГА / WARNING'; }
        else if (line.contains('TIP')) { alertType = 'success'; alertTitle = 'ПОРАДА / TIP'; }
        else { alertTitle = 'ПРИМІТКА / NOTE'; }

        sb.writeln('<div class="alert-box alert-$alertType"><div class="alert-title">$alertTitle</div><div class="alert-content">');
      } else if (line.trim().startsWith('>')) {
        final alertContent = line.trim().replaceFirst('>', '').trim();
        sb.writeln('<p>${formatInlineMarkdown(alertContent, currentSkill, allSkills)}</p>');
      } else if (line.trim().isEmpty) {
        // empty line
      } else if (line.trim() == '---') {
        sb.writeln('<hr class="doc-divider">');
      } else {
        sb.writeln('<p class="doc-p">${formatInlineMarkdown(line, currentSkill, allSkills)}</p>');
      }
    }
  }

  if (inTable) sb.writeln('</tbody></table></div>');
  if (inList) sb.writeln('</ul>');

  return sb.toString();
}

String formatInlineMarkdown(String text, SkillInfo currentSkill, Map<String, SkillInfo> allSkills) {
  String result = escapeHtml(text);

  // Bold
  result = result.replaceAllMapped(RegExp(r'\*\*(.+?)\*\*'), (m) => '<strong>${m[1]}</strong>');
  // Italic
  result = result.replaceAllMapped(RegExp(r'\*(.+?)\*'), (m) => '<em>${m[1]}</em>');
  // Inline code
  result = result.replaceAllMapped(RegExp(r'`([^`]+)`'), (m) => '<code class="inline-code">${m[1]}</code>');

  final placeholders = <String, String>{};
  int phIndex = 0;

  // 1. Extract explicit markdown links first
  result = result.replaceAllMapped(RegExp(r'\[([^\]]+)\]\(([^)]+)\)'), (m) {
    final title = m[1]!;
    final target = m[2]!;

    String targetUrl = target;
    if (target.endsWith('.md')) {
      for (final skill in allSkills.values) {
        if (target.contains(skill.id) || target.endsWith(skill.relativePath)) {
          targetUrl = computeRelativePath(currentSkill.htmlRelativePath, skill.htmlRelativePath);
          final linkHtml = '<a href="$targetUrl" class="skill-ref-link" title="${escapeHtml(skill.description)}">$title <span class="ext-icon">↗</span></a>';
          final ph = '___LINK_PLACEHOLDER_${phIndex++}___';
          placeholders[ph] = linkHtml;
          return ph;
        }
      }
      targetUrl = target.replaceAll('.md', '.html');
    }
    final linkHtml = '<a href="$targetUrl" class="doc-link">$title</a>';
    final ph = '___LINK_PLACEHOLDER_${phIndex++}___';
    placeholders[ph] = linkHtml;
    return ph;
  });

  // 2. Convert bare skill id mentions (only if not already part of a placeholder or tag)
  for (final skill in allSkills.values) {
    if (skill.id != currentSkill.id) {
      final regex = RegExp('\\b(${RegExp.escape(skill.id)})\\b');
      if (regex.hasMatch(result)) {
        final relHtml = computeRelativePath(currentSkill.htmlRelativePath, skill.htmlRelativePath);
        result = result.replaceAllMapped(regex, (m) {
          final ph = '___LINK_PLACEHOLDER_${phIndex++}___';
          placeholders[ph] = '<a href="$relHtml" class="skill-ref-badge" title="Скіл: ${skill.name} (${getCategoryUa(skill.category)})">${m[1]}</a>';
          return ph;
        });
      }
    }
  }

  // 3. Restore placeholders
  placeholders.forEach((ph, html) {
    result = result.replaceAll(ph, html);
  });

  return result;
}

String getSharedStyles() {
  return '''
:root {
  --bg-primary: #0b0f19;
  --bg-secondary: #111827;
  --bg-card: rgba(17, 24, 39, 0.75);
  --bg-card-hover: rgba(31, 41, 55, 0.9);
  --border-color: rgba(255, 255, 255, 0.08);
  --border-accent: rgba(255, 222, 63, 0.35);
  
  --brand-primary: #FFDE3F;
  --brand-primary-hover: #FACC15;
  --brand-glow: rgba(255, 222, 63, 0.18);
  
  --text-primary: #F9FAFB;
  --text-secondary: #9CA3AF;
  --text-muted: #6B7280;
  
  --success: #10B981;
  --success-bg: rgba(16, 185, 129, 0.12);
  --error: #EF4444;
  --error-bg: rgba(239, 68, 68, 0.12);
  --warning: #F59E0B;
  --warning-bg: rgba(245, 158, 11, 0.12);
  --info: #3B82F6;
  --info-bg: rgba(59, 130, 246, 0.12);
  
  --radius-sm: 8px;
  --radius-md: 14px;
  --radius-lg: 20px;
  --shadow-card: 0 10px 30px -10px rgba(0, 0, 0, 0.6);
  --font-heading: 'Outfit', -apple-system, BlinkMacSystemFont, sans-serif;
  --font-body: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
  --font-mono: 'JetBrains Mono', 'Fira Code', monospace;
}

[data-theme="light"] {
  --bg-primary: #F8FAFC;
  --bg-secondary: #FFFFFF;
  --bg-card: rgba(255, 255, 255, 0.9);
  --bg-card-hover: #FFFFFF;
  --border-color: rgba(0, 0, 0, 0.08);
  --border-accent: rgba(217, 119, 6, 0.35);
  
  --brand-primary: #D97706;
  --brand-primary-hover: #B45309;
  --brand-glow: rgba(217, 119, 6, 0.12);
  
  --text-primary: #0F172A;
  --text-secondary: #475569;
  --text-muted: #94A3B8;
  
  --shadow-card: 0 10px 25px -5px rgba(0, 0, 0, 0.06);
}

* { box-sizing: border-box; margin: 0; padding: 0; }
body {
  background-color: var(--bg-primary);
  color: var(--text-primary);
  font-family: var(--font-body);
  line-height: 1.6;
  -webkit-font-smoothing: antialiased;
  min-height: 100vh;
}

/* Header */
.top-nav {
  position: sticky;
  top: 0;
  z-index: 100;
  backdrop-filter: blur(16px);
  -webkit-backdrop-filter: blur(16px);
  background: rgba(11, 15, 25, 0.8);
  border-bottom: 1px solid var(--border-color);
  padding: 0.75rem 2rem;
  display: flex;
  align-items: center;
  justify-content: space-between;
}
[data-theme="light"] .top-nav {
  background: rgba(248, 250, 252, 0.85);
}
.nav-brand {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  text-decoration: none;
  color: var(--text-primary);
  font-family: var(--font-heading);
  font-weight: 700;
  font-size: 1.15rem;
}
.brand-logo {
  background: linear-gradient(135deg, var(--brand-primary), #FB923C);
  color: #000;
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: var(--radius-sm);
  font-weight: 800;
  font-size: 1rem;
}
.nav-breadcrumbs {
  font-size: 0.85rem;
  color: var(--text-secondary);
  display: flex;
  align-items: center;
  gap: 0.5rem;
}
.nav-breadcrumbs a {
  color: var(--text-secondary);
  text-decoration: none;
  transition: color 0.2s;
}
.nav-breadcrumbs a:hover {
  color: var(--brand-primary);
}
.nav-actions {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}
.btn-icon {
  background: var(--bg-card);
  border: 1px solid var(--border-color);
  color: var(--text-primary);
  padding: 0.45rem 0.85rem;
  border-radius: var(--radius-sm);
  cursor: pointer;
  font-size: 0.85rem;
  display: flex;
  align-items: center;
  gap: 0.4rem;
  font-weight: 600;
  transition: all 0.2s ease;
}
.btn-icon:hover {
  background: var(--bg-card-hover);
  border-color: var(--border-accent);
  color: var(--brand-primary);
}

/* Container */
.container {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2.5rem 1.5rem 5rem 1.5rem;
}

/* Hero Section */
.hero {
  background: var(--bg-card);
  border: 1px solid var(--border-color);
  border-radius: var(--radius-lg);
  padding: 2.5rem;
  margin-bottom: 2.5rem;
  box-shadow: var(--shadow-card);
  position: relative;
  overflow: hidden;
}
.hero::before {
  content: '';
  position: absolute;
  top: 0; left: 0; right: 0; height: 3px;
  background: linear-gradient(90deg, var(--brand-primary), #38BDF8, #A855F7);
}
.hero-badges {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
  margin-bottom: 1rem;
}
.badge {
  font-size: 0.75rem;
  font-weight: 600;
  padding: 0.25rem 0.65rem;
  border-radius: 9999px;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}
.badge-category {
  background: var(--brand-glow);
  color: var(--brand-primary);
  border: 1px solid var(--border-accent);
}
.badge-tag {
  background: rgba(255, 255, 255, 0.05);
  color: var(--text-secondary);
  border: 1px solid var(--border-color);
}
.hero-title {
  font-family: var(--font-heading);
  font-size: 2.25rem;
  font-weight: 800;
  margin-bottom: 0.75rem;
  color: var(--text-primary);
}
.hero-description {
  font-size: 1.1rem;
  color: var(--text-secondary);
  line-height: 1.6;
}

/* Section Headings */
.doc-h1 { font-family: var(--font-heading); font-size: 2rem; margin: 2rem 0 1rem; color: var(--text-primary); }
.doc-h2 { font-family: var(--font-heading); font-size: 1.45rem; margin: 2.25rem 0 1rem; padding-bottom: 0.5rem; border-bottom: 1px solid var(--border-color); color: var(--text-primary); position: relative; }
.heading-anchor { color: var(--text-muted); text-decoration: none; margin-right: 0.25rem; opacity: 0; transition: opacity 0.2s; }
.doc-h2:hover .heading-anchor { opacity: 1; }
.doc-h3 { font-family: var(--font-heading); font-size: 1.2rem; margin: 1.5rem 0 0.75rem; color: var(--brand-primary); }
.doc-h4 { font-size: 1.05rem; margin: 1.2rem 0 0.5rem; color: var(--text-primary); }
.doc-p { margin-bottom: 1rem; color: var(--text-primary); }
.doc-divider { border: none; height: 1px; background: var(--border-color); margin: 2.5rem 0; }

/* Lists */
.doc-list, .doc-ordered-list {
  padding-left: 1.5rem;
  margin-bottom: 1.25rem;
}
.doc-list li, .doc-ordered-list li {
  margin-bottom: 0.4rem;
}

/* Links & Badges */
.doc-link {
  color: var(--brand-primary);
  text-decoration: none;
  border-bottom: 1px dashed var(--brand-primary);
}
.doc-link:hover {
  border-bottom-style: solid;
}
.skill-ref-badge {
  display: inline-flex;
  align-items: center;
  background: rgba(59, 130, 246, 0.12);
  color: #60A5FA;
  border: 1px solid rgba(59, 130, 246, 0.3);
  padding: 0.15rem 0.5rem;
  border-radius: var(--radius-sm);
  font-size: 0.85rem;
  font-family: var(--font-mono);
  text-decoration: none;
  transition: all 0.2s ease;
  margin: 0 0.2rem;
}
.skill-ref-badge:hover {
  background: rgba(59, 130, 246, 0.25);
  border-color: #60A5FA;
  transform: translateY(-1px);
}
.skill-ref-link {
  color: #38BDF8;
  font-weight: 600;
  text-decoration: none;
  transition: all 0.2s;
}
.skill-ref-link:hover {
  color: var(--brand-primary);
  text-decoration: underline;
}
.ext-icon { font-size: 0.75rem; }

/* Code Blocks */
.inline-code {
  background: rgba(255, 255, 255, 0.08);
  color: var(--brand-primary);
  padding: 0.2rem 0.4rem;
  border-radius: 4px;
  font-family: var(--font-mono);
  font-size: 0.88em;
}
[data-theme="light"] .inline-code {
  background: rgba(0, 0, 0, 0.06);
}
.code-block-wrapper {
  background: #090d16;
  border: 1px solid var(--border-color);
  border-radius: var(--radius-md);
  margin: 1.25rem 0;
  overflow: hidden;
}
[data-theme="light"] .code-block-wrapper {
  background: #F1F5F9;
}
.code-header {
  background: rgba(0, 0, 0, 0.3);
  padding: 0.45rem 1rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid var(--border-color);
}
.code-lang {
  font-size: 0.75rem;
  text-transform: uppercase;
  color: var(--text-muted);
  font-family: var(--font-mono);
  font-weight: 700;
}
.copy-btn {
  background: transparent;
  border: 1px solid var(--border-color);
  color: var(--text-secondary);
  padding: 0.2rem 0.55rem;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.75rem;
  display: flex;
  align-items: center;
  gap: 0.3rem;
  transition: all 0.2s;
}
.copy-btn:hover {
  color: var(--text-primary);
  border-color: var(--brand-primary);
}
pre {
  padding: 1.2rem;
  overflow-x: auto;
  font-family: var(--font-mono);
  font-size: 0.9rem;
  line-height: 1.5;
}

/* Tables */
.table-responsive {
  overflow-x: auto;
  margin: 1.5rem 0;
}
.doc-table {
  width: 100%;
  border-collapse: collapse;
  background: var(--bg-card);
  border-radius: var(--radius-md);
  overflow: hidden;
  border: 1px solid var(--border-color);
}
.doc-table th, .doc-table td {
  padding: 0.85rem 1rem;
  text-align: left;
  border-bottom: 1px solid var(--border-color);
}
.doc-table th {
  background: rgba(0, 0, 0, 0.2);
  font-family: var(--font-heading);
  font-weight: 700;
  color: var(--text-primary);
  font-size: 0.9rem;
}
[data-theme="light"] .doc-table th {
  background: rgba(0, 0, 0, 0.03);
}

/* Mermaid Diagrams */
.mermaid-container {
  background: var(--bg-card);
  border: 1px solid var(--border-color);
  border-radius: var(--radius-md);
  padding: 2rem 1.5rem;
  margin: 2rem 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  overflow-x: auto;
  box-shadow: var(--shadow-card);
}
.mermaid-header {
  font-family: var(--font-heading);
  font-size: 1.1rem;
  font-weight: 700;
  color: var(--brand-primary);
  margin-bottom: 1.25rem;
  text-align: center;
}
.mermaid-container .mermaid {
  width: 100%;
  display: flex;
  justify-content: center;
  min-height: 240px;
}
.mermaid-container .mermaid svg {
  width: 100% !important;
  max-width: 950px !important;
  height: auto !important;
  font-family: var(--font-body) !important;
}

/* Checklist */
.checklist-item {
  background: var(--bg-card);
  border: 1px solid var(--border-color);
  padding: 0.75rem 1rem;
  border-radius: var(--radius-sm);
  margin-bottom: 0.5rem;
  transition: all 0.2s;
}
.checklist-item:hover {
  border-color: var(--border-accent);
}
.checkbox-container {
  display: flex;
  align-items: flex-start;
  gap: 0.75rem;
  cursor: pointer;
}
.checkbox-container input {
  margin-top: 0.3rem;
  cursor: pointer;
}
.progress-card {
  background: var(--bg-card);
  border: 1px solid var(--border-color);
  border-radius: var(--radius-md);
  padding: 1.25rem;
  margin-bottom: 1.5rem;
}
.progress-bar-bg {
  height: 8px;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 9999px;
  overflow: hidden;
  margin: 0.5rem 0;
}
.progress-bar-fill {
  height: 100%;
  background: linear-gradient(90deg, var(--brand-primary), var(--success));
  width: 0%;
  transition: width 0.3s ease;
}

/* Alerts */
.alert-box {
  border-radius: var(--radius-md);
  padding: 1.2rem;
  margin: 1.25rem 0;
  border-left: 4px solid;
}
.alert-info { background: var(--info-bg); border-left-color: var(--info); }
.alert-warning { background: var(--warning-bg); border-left-color: var(--warning); }
.alert-error { background: var(--error-bg); border-left-color: var(--error); }
.alert-success { background: var(--success-bg); border-left-color: var(--success); }
.alert-title { font-weight: 700; font-size: 0.85rem; margin-bottom: 0.4rem; text-transform: uppercase; }

/* Footer */
.footer {
  margin-top: 4rem;
  padding-top: 2rem;
  border-top: 1px solid var(--border-color);
  text-align: center;
  font-size: 0.85rem;
  color: var(--text-muted);
}
''';
}

String getSharedScript() {
  return '''
// Theme Management
function initTheme() {
  const saved = localStorage.getItem('agent_doc_theme') || 'dark';
  document.documentElement.setAttribute('data-theme', saved);
  updateThemeButton(saved);
}

function toggleTheme() {
  const current = document.documentElement.getAttribute('data-theme') || 'dark';
  const next = current === 'dark' ? 'light' : 'dark';
  document.documentElement.setAttribute('data-theme', next);
  localStorage.setItem('agent_doc_theme', next);
  updateThemeButton(next);
}

function updateThemeButton(theme) {
  const icon = document.getElementById('theme-icon');
  const label = document.getElementById('theme-text');
  if (icon && label) {
    if (theme === 'dark') {
      icon.textContent = '🌙';
      label.setAttribute('data-i18n', 'dark_theme');
      if (currentLang === 'ua') label.textContent = 'Темна';
      else label.textContent = 'Dark';
    } else {
      icon.textContent = '☀️';
      label.setAttribute('data-i18n', 'light_theme');
      if (currentLang === 'ua') label.textContent = 'Світла';
      else label.textContent = 'Light';
    }
  }
}

// Language Management (UA / EN)
let currentLang = localStorage.getItem('agent_doc_lang') || 'ua';

const translations = {
  ua: {
    portal_title: "Центр Документації Агентів",
    all_skills: "Всі скіли",
    project_rules: "Правила Проєкту (AGENTS.md)",
    search_placeholder: "Пошук скілів за назвою, категорією або тригерами...",
    stats_total_skills: "Всього Скілів",
    stats_categories: "Категорій / Шарів",
    stats_rules: "Правил Архітектури",
    stats_connected: "100% Взаємозв'язані",
    filter_all: "Всі",
    copy: "Копіювати",
    copied: "Скопійовано!",
    progress: "Прогрес виконання",
    checklist_title: "Чекліст верифікації та виконання",
    sub_skills_title: "Пов'язані та рекомендовані скіли",
    dark_theme: "Темна",
    light_theme: "Світла",
    lang_btn: "UA 🇺🇦",
    back_to_portal: "← До Порталу",
    view_docs: "Читати",
    rules_overview: "Огляд архітектурних правил та контрактів"
  },
  en: {
    portal_title: "Agent Documentation Hub",
    all_skills: "All Skills",
    project_rules: "Project Rules (AGENTS.md)",
    search_placeholder: "Search skills by name, layer, or triggers...",
    stats_total_skills: "Total Skills",
    stats_categories: "Categories / Layers",
    stats_rules: "Architectural Rules",
    stats_connected: "100% Interconnected",
    filter_all: "All",
    copy: "Copy",
    copied: "Copied!",
    progress: "Execution Progress",
    checklist_title: "Verification & Quality Checklist",
    sub_skills_title: "Related & Referenced Skills",
    dark_theme: "Dark",
    light_theme: "Light",
    lang_btn: "EN 🇬🇧",
    back_to_portal: "← Back to Portal",
    view_docs: "Explore",
    rules_overview: "Architectural rules & layer interaction contracts"
  }
};

function initLanguage() {
  setLanguage(currentLang);
}

function toggleLanguage() {
  const next = currentLang === 'ua' ? 'en' : 'ua';
  setLanguage(next);
}

function setLanguage(lang) {
  currentLang = lang;
  localStorage.setItem('agent_doc_lang', lang);
  
  const dict = translations[lang] || translations.ua;
  document.querySelectorAll('[data-i18n]').forEach(el => {
    const key = el.getAttribute('data-i18n');
    if (dict[key]) {
      if (el.tagName === 'INPUT' && el.getAttribute('placeholder')) {
        el.setAttribute('placeholder', dict[key]);
      } else {
        el.textContent = dict[key];
      }
    }
  });

  const langBtn = document.getElementById('lang-text');
  if (langBtn) {
    langBtn.textContent = lang === 'ua' ? '🇺🇦 UA' : '🇬🇧 EN';
  }

  // Update category texts if available
  document.querySelectorAll('[data-cat-ua]').forEach(el => {
    if (lang === 'ua') {
      el.textContent = el.getAttribute('data-cat-ua');
    } else {
      el.textContent = el.getAttribute('data-cat-en');
    }
  });

  const theme = document.documentElement.getAttribute('data-theme') || 'dark';
  updateThemeButton(theme);
}

// Copy Code
function copyCode(button) {
  const wrapper = button.closest('.code-block-wrapper');
  const code = wrapper.querySelector('code').innerText;
  navigator.clipboard.writeText(code).then(() => {
    const btnText = button.querySelector('.btn-text');
    const original = btnText.innerText;
    btnText.innerText = currentLang === 'ua' ? 'Скопійовано!' : 'Copied!';
    button.style.borderColor = 'var(--success)';
    button.style.color = 'var(--success)';
    setTimeout(() => {
      btnText.innerText = original;
      button.style.borderColor = '';
      button.style.color = '';
    }, 2000);
  });
}

// Checklist Progress
function updateChecklistProgress() {
  const checkboxes = document.querySelectorAll('.checklist-item input[type="checkbox"]');
  const checked = document.querySelectorAll('.checklist-item input[type="checkbox"]:checked');
  if (!checkboxes.length) return;

  const percent = Math.round((checked.length / checkboxes.length) * 100);
  const fill = document.getElementById('checklist-progress-fill');
  const text = document.getElementById('checklist-progress-text');
  if (fill) fill.style.width = percent + '%';
  if (text) text.textContent = percent + '% (' + checked.length + '/' + checkboxes.length + ')';
}

document.addEventListener('DOMContentLoaded', () => {
  initTheme();
  initLanguage();
  updateChecklistProgress();
  if (typeof mermaid !== 'undefined') {
    const isLight = document.documentElement.getAttribute('data-theme') === 'light';
    mermaid.initialize({
      startOnLoad: true,
      theme: isLight ? 'default' : 'dark',
      themeVariables: {
        fontSize: '14px',
        fontFamily: 'Inter, Outfit, sans-serif',
        primaryColor: isLight ? '#f1f5f9' : '#1e293b',
        primaryTextColor: isLight ? '#0f172a' : '#f8fafc',
        primaryBorderColor: isLight ? '#d97706' : '#FFDE3F',
        lineColor: isLight ? '#2563eb' : '#60a5fa',
        secondaryColor: isLight ? '#ffffff' : '#111827',
        tertiaryColor: isLight ? '#f8fafc' : '#0b0f19'
      },
      flowchart: {
        useMaxWidth: true,
        htmlLabels: true,
        curve: 'basis',
        nodeSpacing: 40,
        rankSpacing: 45
      },
      securityLevel: 'loose'
    });
  }
});
''';
}

String generateSkillHtml(SkillInfo skill, Map<String, SkillInfo> allSkills) {
  final pathToAgentsRoot = computeRelativePath(skill.htmlRelativePath, 'index.html');
  final pathToRules = computeRelativePath(skill.htmlRelativePath, 'agents-rules.html');
  final categoryUa = getCategoryUa(skill.category);

  final contentHtml = convertMarkdownToHtml(skill.rawContent, skill, allSkills);

  // Generate Related Skills section
  final relatedSb = StringBuffer();
  if (skill.referencedSkillIds.isNotEmpty) {
    relatedSb.writeln('<div class="related-skills-section" style="margin-top: 3rem;">');
    relatedSb.writeln('<h3 class="doc-h3" data-i18n="sub_skills_title">Пов\'язані та рекомендовані скіли</h3>');
    relatedSb.writeln('<div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 1rem; margin-top: 1rem;">');

    for (final refId in skill.referencedSkillIds) {
      final refSkill = allSkills[refId];
      if (refSkill != null) {
        final relPath = computeRelativePath(skill.htmlRelativePath, refSkill.htmlRelativePath);
        final refCatUa = getCategoryUa(refSkill.category);
        relatedSb.writeln('''
<a href="$relPath" class="checklist-item" style="text-decoration: none; display: block;">
  <div style="font-weight: 700; color: var(--brand-primary); font-family: var(--font-heading); margin-bottom: 0.3rem;">
    ${refSkill.name} ↗
  </div>
  <div style="font-size: 0.75rem; color: var(--text-muted); margin-bottom: 0.5rem;" data-cat-ua="$refCatUa" data-cat-en="${refSkill.category}">
    $refCatUa
  </div>
  <div style="font-size: 0.85rem; color: var(--text-secondary); line-height: 1.4;">
    ${escapeHtml(refSkill.description.length > 110 ? '${refSkill.description.substring(0, 110)}...' : refSkill.description)}
  </div>
</a>''');
      }
    }
    relatedSb.writeln('</div></div>');
  }

  return '''<!DOCTYPE html>
<html lang="uk" data-theme="dark">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${escapeHtml(skill.name)} — Agent Skill Documentation</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;600;700&family=Outfit:wght@600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/github-dark-dimmed.min.css">
  <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/languages/dart.min.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/languages/yaml.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js"></script>
  <style>
${getSharedStyles()}
  </style>
</head>
<body>
  <header class="top-nav">
    <div style="display: flex; align-items: center; gap: 1.5rem;">
      <a href="$pathToAgentsRoot" class="nav-brand">
        <div class="brand-logo">AG</div>
        <span>Antigravity Docs</span>
      </a>
      <div class="nav-breadcrumbs">
        <a href="$pathToAgentsRoot" data-i18n="portal_title">Центр Документації</a>
        <span>/</span>
        <span data-cat-ua="$categoryUa" data-cat-en="${skill.category}">$categoryUa</span>
        <span>/</span>
        <span style="color: var(--text-primary); font-weight: 600;">${skill.id}</span>
      </div>
    </div>
    <div class="nav-actions">
      <a href="$pathToRules" class="btn-icon">
        <span>📜</span>
        <span data-i18n="project_rules">Правила AGENTS.md</span>
      </a>
      <button class="btn-icon" onclick="toggleLanguage()">
        <span id="lang-text">🇺🇦 UA</span>
      </button>
      <button class="btn-icon" onclick="toggleTheme()">
        <span id="theme-icon">🌙</span>
        <span id="theme-text" data-i18n="dark_theme">Темна</span>
      </button>
    </div>
  </header>

  <main class="container">
    <section class="hero">
      <div class="hero-badges">
        <span class="badge badge-category" data-cat-ua="$categoryUa" data-cat-en="${skill.category}">$categoryUa</span>
        <span class="badge badge-tag">SKILL</span>
        ${skill.triggers.map((t) => '<span class="badge badge-tag">#$t</span>').join('\n')}
      </div>
      <h1 class="hero-title">${escapeHtml(skill.name)}</h1>
      <p class="hero-description">${escapeHtml(skill.description)}</p>
    </section>

    <div class="progress-card">
      <div style="display: flex; justify-content: space-between; font-size: 0.85rem; font-weight: 600;">
        <span data-i18n="progress">Прогрес виконання</span>
        <span id="checklist-progress-text">0%</span>
      </div>
      <div class="progress-bar-bg">
        <div class="progress-bar-fill" id="checklist-progress-fill"></div>
      </div>
    </div>

    <article class="doc-content">
$contentHtml
    </article>

$relatedSb

    <footer class="footer">
      <p>© 2026 Antigravity Flutter Architecture • Generated automatically with <a href="${computeRelativePath(skill.htmlRelativePath, 'skills/documentation/skill-html-doc-generator/skill-html-doc-generator.html')}" class="doc-link">skill-html-doc-generator</a></p>
    </footer>
  </main>

  <script>
${getSharedScript()}
    hljs.highlightAll();
  </script>
</body>
</html>''';
}

String generateAgentsRulesHtml(String agentsMdContent, Map<String, SkillInfo> allSkills) {
  final currentSkillMock = SkillInfo(
    id: 'agents-rules',
    name: 'AGENTS.md Project Rules',
    description: 'Master architecture rules, Clean Architecture laws, state management constraints, and AI workflow guidelines.',
    category: 'Architecture Rules',
    relativePath: 'AGENTS.md',
    htmlRelativePath: 'agents-rules.html',
    markdownFile: File('AGENTS.md'),
    rawContent: agentsMdContent,
    triggers: ['clean-architecture', 'bloc', 'rules', 'linter', 'contracts'],
    referencedSkillIds: [],
  );

  final contentHtml = convertMarkdownToHtml(agentsMdContent, currentSkillMock, allSkills);

  return '''<!DOCTYPE html>
<html lang="uk" data-theme="dark">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>AGENTS.md — Правила та Стандарти Проєкту</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;600;700&family=Outfit:wght@600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/github-dark-dimmed.min.css">
  <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/languages/dart.min.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/languages/yaml.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js"></script>
  <style>
${getSharedStyles()}
  </style>
</head>
<body>
  <header class="top-nav">
    <div style="display: flex; align-items: center; gap: 1.5rem;">
      <a href="index.html" class="nav-brand">
        <div class="brand-logo">AG</div>
        <span>Antigravity Docs</span>
      </a>
      <div class="nav-breadcrumbs">
        <a href="index.html" data-i18n="portal_title">Центр Документації</a>
        <span>/</span>
        <span style="color: var(--text-primary); font-weight: 600;">AGENTS.md Rules</span>
      </div>
    </div>
    <div class="nav-actions">
      <a href="index.html" class="btn-icon">
        <span data-i18n="back_to_portal">← До Порталу</span>
      </a>
      <button class="btn-icon" onclick="toggleLanguage()">
        <span id="lang-text">🇺🇦 UA</span>
      </button>
      <button class="btn-icon" onclick="toggleTheme()">
        <span id="theme-icon">🌙</span>
        <span id="theme-text" data-i18n="dark_theme">Темна</span>
      </button>
    </div>
  </header>

  <main class="container">
    <section class="hero">
      <div class="hero-badges">
        <span class="badge badge-category">ARCHITECTURE CORE</span>
        <span class="badge badge-tag">RULES</span>
        <span class="badge badge-tag">#clean-architecture</span>
        <span class="badge badge-tag">#bloc</span>
        <span class="badge badge-tag">#linters</span>
      </div>
      <h1 class="hero-title">AGENTS.md — Архітектурний Кодекс Проєкту</h1>
      <p class="hero-description" data-i18n="rules_overview">
        Офіційні правила, обмеження шарів Clean Architecture, вимоги до стану BLoC, правила лінтингу та політика безпеки для ШІ-агентів та розробників.
      </p>
    </section>

    <article class="doc-content">
$contentHtml
    </article>

    <footer class="footer">
      <p>© 2026 Antigravity Flutter Architecture • Project Rules & Governance</p>
    </footer>
  </main>

  <script>
${getSharedScript()}
    hljs.highlightAll();
  </script>
</body>
</html>''';
}

String generateIndexHubHtml(List<SkillInfo> skills) {
  // Sort skills by category then name
  skills.sort((a, b) {
    final catComp = a.category.compareTo(b.category);
    if (catComp != 0) return catComp;
    return a.name.compareTo(b.name);
  });

  final categories = skills.map((s) => s.category).toSet().toList()..sort();

  final cardsSb = StringBuffer();
  for (final skill in skills) {
    final catUa = getCategoryUa(skill.category);
    cardsSb.writeln('''
<div class="skill-card" data-category="${escapeHtml(skill.category)}" data-search="${escapeHtml('${skill.name} ${skill.id} ${skill.description} ${skill.category} $catUa ${skill.triggers.join(' ')}'.toLowerCase())}">
  <div class="card-main-content">
    <div class="card-header">
      <span class="card-category-badge" data-cat-ua="$catUa" data-cat-en="${skill.category}">
        <span class="badge-dot"></span>
        <span>$catUa</span>
      </span>
      <span class="card-refs-badge" title="Зв'язків з іншими скілами">🔗 ${skill.referencedSkillIds.length}</span>
    </div>
    <h3 class="card-title">
      <a href="${skill.htmlRelativePath}">${skill.name}</a>
    </h3>
    <p class="card-desc">
      ${escapeHtml(skill.description.isNotEmpty ? skill.description : 'Specialized agent skill guide and architectural instructions.')}
    </p>
  </div>
  <div class="card-footer">
    <div class="card-tags">
      ${skill.triggers.take(2).map((t) => '<span class="tag">#$t</span>').join(' ')}
    </div>
    <a href="${skill.htmlRelativePath}" class="card-btn">
      <span data-i18n="view_docs">Читати</span>
      <span class="btn-arrow">→</span>
    </a>
  </div>
</div>''');
  }

  final categoryChipsSb = StringBuffer();
  for (final c in categories) {
    final cUa = getCategoryUa(c);
    categoryChipsSb.writeln('<button class="filter-chip" onclick="setCategoryFilter(\'${escapeHtml(c)}\', this)" data-cat-ua="$cUa" data-cat-en="$c">$cUa</button>');
  }

  return '''<!DOCTYPE html>
<html lang="uk" data-theme="dark">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Центр Документації Агентів — Antigravity Portal</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;600;700&family=Outfit:wght@600;700;800&display=swap" rel="stylesheet">
  <script src="https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js"></script>
  <style>
${getSharedStyles()}
    .search-section {
      margin-bottom: 2rem;
    }
    .search-box {
      width: 100%;
      background: var(--bg-card);
      border: 1px solid var(--border-color);
      padding: 1rem 1.25rem;
      border-radius: var(--radius-md);
      color: var(--text-primary);
      font-size: 1.05rem;
      font-family: var(--font-body);
      outline: none;
      transition: all 0.2s;
    }
    .search-box:focus {
      border-color: var(--brand-primary);
      box-shadow: 0 0 0 3px var(--brand-glow);
    }
    .filter-chips {
      display: flex;
      flex-wrap: wrap;
      gap: 0.5rem;
      margin-top: 1rem;
    }
    .filter-chip {
      background: var(--bg-card);
      border: 1px solid var(--border-color);
      color: var(--text-secondary);
      padding: 0.4rem 0.85rem;
      border-radius: 9999px;
      font-size: 0.82rem;
      cursor: pointer;
      font-weight: 600;
      transition: all 0.2s;
    }
    .filter-chip.active, .filter-chip:hover {
      background: var(--brand-primary);
      color: #000;
      border-color: var(--brand-primary);
    }
    .stats-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
      gap: 1rem;
      margin-bottom: 2.5rem;
    }
    .stat-card {
      background: var(--bg-card);
      border: 1px solid var(--border-color);
      border-radius: var(--radius-md);
      padding: 1.25rem;
      text-align: center;
    }
    .stat-val {
      font-family: var(--font-heading);
      font-size: 2rem;
      font-weight: 800;
      color: var(--brand-primary);
    }
    .stat-label {
      font-size: 0.82rem;
      color: var(--text-secondary);
      text-transform: uppercase;
      letter-spacing: 0.05em;
      margin-top: 0.25rem;
    }
    .skills-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(330px, 1fr));
      gap: 1.5rem;
    }
    .skill-card {
      background: linear-gradient(180deg, rgba(22, 30, 49, 0.75) 0%, rgba(15, 23, 42, 0.85) 100%);
      border: 1px solid rgba(255, 255, 255, 0.08);
      border-radius: var(--radius-md);
      padding: 1.5rem;
      display: flex;
      flex-direction: column;
      justify-content: space-between;
      transition: all 0.25s cubic-bezier(0.16, 1, 0.3, 1);
      position: relative;
      backdrop-filter: blur(12px);
      box-shadow: 0 4px 20px -4px rgba(0, 0, 0, 0.4);
    }
    [data-theme="light"] .skill-card {
      background: linear-gradient(180deg, rgba(255, 255, 255, 0.95) 0%, rgba(248, 250, 252, 0.9) 100%);
      border-color: rgba(0, 0, 0, 0.08);
      box-shadow: 0 4px 20px -4px rgba(0, 0, 0, 0.05);
    }
    .skill-card:hover {
      border-color: rgba(255, 222, 63, 0.4);
      transform: translateY(-4px);
      box-shadow: 0 16px 32px -8px rgba(0, 0, 0, 0.6), 0 0 20px -5px var(--brand-glow);
    }
    [data-theme="light"] .skill-card:hover {
      border-color: rgba(217, 119, 6, 0.4);
      box-shadow: 0 16px 32px -8px rgba(0, 0, 0, 0.1), 0 0 20px -5px var(--brand-glow);
    }
    .card-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 0.85rem;
    }
    .card-category-badge {
      display: inline-flex;
      align-items: center;
      gap: 0.4rem;
      font-size: 0.72rem;
      font-weight: 700;
      padding: 0.25rem 0.65rem;
      border-radius: 9999px;
      background: rgba(255, 222, 63, 0.1);
      color: var(--brand-primary);
      border: 1px solid rgba(255, 222, 63, 0.25);
      letter-spacing: 0.02em;
      max-width: 80%;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }
    .badge-dot {
      width: 6px;
      height: 6px;
      border-radius: 50%;
      background: var(--brand-primary);
      flex-shrink: 0;
    }
    .card-refs-badge {
      font-size: 0.75rem;
      color: var(--text-secondary);
      font-family: var(--font-mono);
      font-weight: 600;
      background: rgba(255, 255, 255, 0.05);
      padding: 0.2rem 0.5rem;
      border-radius: 6px;
      border: 1px solid var(--border-color);
    }
    .card-title {
      font-family: var(--font-heading);
      font-size: 1.25rem;
      font-weight: 700;
      margin-bottom: 0.6rem;
      line-height: 1.35;
    }
    .card-title a {
      color: var(--text-primary);
      text-decoration: none;
      transition: color 0.2s;
    }
    .card-title a:hover {
      color: var(--brand-primary);
    }
    .card-desc {
      font-size: 0.88rem;
      color: var(--text-secondary);
      line-height: 1.55;
      margin-bottom: 1.25rem;
      display: -webkit-box;
      -webkit-line-clamp: 4;
      -webkit-box-orient: vertical;
      overflow: hidden;
    }
    .card-footer {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding-top: 0.85rem;
      border-top: 1px solid var(--border-color);
      gap: 0.75rem;
    }
    .card-tags {
      display: flex;
      flex-wrap: wrap;
      gap: 0.35rem;
      max-width: 60%;
      overflow: hidden;
    }
    .tag {
      font-size: 0.7rem;
      color: var(--text-muted);
      font-family: var(--font-mono);
      background: rgba(255, 255, 255, 0.04);
      padding: 0.15rem 0.4rem;
      border-radius: 4px;
      white-space: nowrap;
    }
    .card-btn {
      display: inline-flex;
      align-items: center;
      gap: 0.35rem;
      font-size: 0.82rem;
      font-weight: 700;
      color: var(--brand-primary);
      background: var(--brand-glow);
      border: 1px solid var(--border-accent);
      padding: 0.4rem 0.8rem;
      border-radius: var(--radius-sm);
      text-decoration: none;
      white-space: nowrap;
      flex-shrink: 0;
      transition: all 0.2s ease;
    }
    .card-btn:hover {
      background: var(--brand-primary);
      color: #000;
      transform: translateX(2px);
    }
    .card-btn:hover .btn-arrow {
      transform: translateX(3px);
    }
    .btn-arrow {
      transition: transform 0.2s;
    }
  </style>
</head>
<body>
  <header class="top-nav">
    <div style="display: flex; align-items: center; gap: 1.5rem;">
      <a href="index.html" class="nav-brand">
        <div class="brand-logo">AG</div>
        <span>Antigravity Portal</span>
      </a>
    </div>
    <div class="nav-actions">
      <a href="agents-rules.html" class="btn-icon">
        <span>📜</span>
        <span data-i18n="project_rules">Правила AGENTS.md</span>
      </a>
      <button class="btn-icon" onclick="toggleLanguage()">
        <span id="lang-text">🇺🇦 UA</span>
      </button>
      <button class="btn-icon" onclick="toggleTheme()">
        <span id="theme-icon">🌙</span>
        <span id="theme-text" data-i18n="dark_theme">Темна</span>
      </button>
    </div>
  </header>

  <main class="container">
    <section class="hero">
      <div class="hero-badges">
        <span class="badge badge-category">SYSTEM HUB</span>
        <span class="badge badge-tag">FLUTTER CLEAN ARCHITECTURE</span>
        <span class="badge badge-tag">BLOC MATRIX</span>
      </div>
      <h1 class="hero-title" data-i18n="portal_title">Центр Документації Агентів</h1>
      <p class="hero-description">
        Повний інтерактивний каталог скілів, архітектурних контрактів, стандартів кодогенерації та правил розробки для Flutter-шаблону. Усі скіли 100% взаємозв'язані гіперпосиланнями.
      </p>
    </section>

    <div class="stats-grid">
      <div class="stat-card">
        <div class="stat-val">${skills.length}</div>
        <div class="stat-label" data-i18n="stats_total_skills">Всього Скілів</div>
      </div>
      <div class="stat-card">
        <div class="stat-val">${categories.length}</div>
        <div class="stat-label" data-i18n="stats_categories">Категорій / Шарів</div>
      </div>
      <div class="stat-card">
        <div class="stat-val">12</div>
        <div class="stat-label" data-i18n="stats_rules">Правил Архітектури</div>
      </div>
      <div class="stat-card">
        <div class="stat-val">100%</div>
        <div class="stat-label" data-i18n="stats_connected">Взаємозв'язані</div>
      </div>
    </div>

    <!-- Interactive Architecture Graph -->
    <div class="mermaid-container" style="margin-bottom: 2.5rem;">
      <div class="mermaid-header">🗺️ Карта Архітектури та Взаємозв'язку Шарів / Architecture Relationship Map</div>
      <div class="mermaid">
flowchart TB
    subgraph STANDARDS ["🏛️ Архітектурні Стандарти та Портал"]
        Hub["🏠 Центр Документації<br/><code>.agents/index.html</code>"]
        Rules["📜 AGENTS.md<br/><code>Правила Архітектури & Лінтинг</code>"]
        Hub <--> Rules
    end

    subgraph CLEAN_ARCH ["⚡ Clean Architecture (Потік даних та залежностей)"]
        direction LR
        Pres["🎨 Presentation Layer<br/><code>BLoC • AutoRoute • UI Kit</code>"]
        Domain["💎 Domain Layer<br/><code>Entities • UseCases • Failures</code>"]
        Data["📦 Data Layer<br/><code>Retrofit • Local DB • DTO Mappers</code>"]
        Infra["🔌 Infrastructure<br/><code>DI Injectable • Dio • Storage</code>"]

        Pres -->|UseCases| Domain
        Domain -->|Repository Interfaces| Data
        Infra -->|DataSources / Config| Data
        Pres -.->|DI Registration| Infra
    end

    subgraph WORKFLOWS ["🛠️ Інженерні Процеси & Нативні Платформи"]
        direction LR
        Bootstrap["🚀 Bootstrap & Adoption"]
        Testing["🧪 Тестування (BLoC / Unit)"]
        Native["📱 Native (iOS / Android)"]
        Git["🌿 Git Workflow"]
    end

    STANDARDS ==> CLEAN_ARCH
    WORKFLOWS ==> CLEAN_ARCH
      </div>
    </div>

    <section class="search-section">
      <input type="text" id="skill-search" class="search-box" placeholder="Пошук скілів за назвою, категорією або тригерами..." data-i18n="search_placeholder" oninput="filterSkills()">
      <div class="filter-chips">
        <button class="filter-chip active" onclick="setCategoryFilter('all', this)" data-i18n="filter_all">Всі</button>
$categoryChipsSb
      </div>
    </section>

    <div class="skills-grid" id="skills-grid">
$cardsSb
    </div>

    <footer class="footer">
      <p>© 2026 Antigravity Flutter Architecture • <a href="agents-rules.html" class="doc-link">AGENTS.md Rules</a></p>
    </footer>
  </main>

  <script>
${getSharedScript()}

    let activeCategory = 'all';

    function setCategoryFilter(category, button) {
      activeCategory = category;
      document.querySelectorAll('.filter-chip').forEach(b => b.classList.remove('active'));
      button.classList.add('active');
      filterSkills();
    }

    function filterSkills() {
      const query = (document.getElementById('skill-search').value || '').toLowerCase().trim();
      const cards = document.querySelectorAll('.skill-card');

      cards.forEach(card => {
        const cat = card.getAttribute('data-category');
        const searchData = card.getAttribute('data-search') || '';

        const matchesCat = (activeCategory === 'all' || cat === activeCategory);
        const matchesQuery = (!query || searchData.includes(query));

        if (matchesCat && matchesQuery) {
          card.style.display = 'flex';
        } else {
          card.style.display = 'none';
        }
      });
    }
  </script>
</body>
</html>''';
}
