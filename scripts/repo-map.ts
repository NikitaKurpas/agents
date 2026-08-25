#!/usr/bin/env -S deno run -q --allow-read

import { dirname, fromFileUrl, join, relative, resolve } from 'jsr:@std/path';

type FrontMatter = {
  summary?: string;
  readWhen?: string[];
};

type Entry = {
  relativePath: string;
  data: FrontMatter;
  error?: string;
};

type TreeNode =
  | { kind: 'dir'; name: string; children: TreeNode[] }
  | { kind: 'file'; name: string; entry: Entry };

const DEFAULT_EXTENSIONS = new Set([
  '.sh',
  '.swift',
  '.ts',
  '.tsx',
  '.js',
  '.jsx',
  '.go',
  '.py',
]);

const EXCLUDED_DIRS = new Set([
  '.git',
  '.idea',
  '.vscode',
  'node_modules',
  'dist',
  'build',
  'coverage',
  'vendor',
  'target',
  'out',
  'tmp',
  'temp',
]);

function parseArgs(argv: string[]) {
  const scriptDir = dirname(fromFileUrl(import.meta.url));
  const defaultRoot = resolve(scriptDir, '..');
  const options: {
    root: string;
    extensions: Set<string>;
  } = {
    root: defaultRoot,
    extensions: DEFAULT_EXTENSIONS,
  };

  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    if (arg === '--root') {
      options.root = resolve(argv[i + 1] ?? '');
      i += 1;
      continue;
    }
  }

  return options;
}

type CommentStyle = {
  linePrefixes: string[];
  block?: { start: string; end: string };
  allowsShebang: boolean;
};

function getCommentStyle(extension: string): CommentStyle {
  switch (extension) {
    case '.sh':
    case '.py':
      return { linePrefixes: ['#'], allowsShebang: true };
    case '.go':
    case '.js':
    case '.jsx':
    case '.ts':
    case '.tsx':
    case '.swift':
      return {
        linePrefixes: ['//'],
        block: { start: '/*', end: '*/' },
        allowsShebang: true,
      };
    default:
      return { linePrefixes: [], allowsShebang: false };
  }
}

function normalizeCommentLines(
  raw: string,
  prefix: string,
  isBlock: boolean
): string[] {
  const lines = raw.split(/\r?\n/);
  if (isBlock) {
    return lines.map((line) => line.replace(/^\s*\*\s?/, ''));
  }
  const escaped = prefix.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  const pattern = new RegExp(`^\\s*${escaped}\\s?`);
  return lines.map((line) => line.replace(pattern, ''));
}

function extractTopLevelComment(
  content: string,
  style: CommentStyle
): { text: string; error?: string } | null {
  let offset = 0;
  if (style.allowsShebang && content.startsWith('#!')) {
    const end = content.indexOf('\n');
    offset = end === -1 ? content.length : end + 1;
  }

  const slice = content.slice(offset);
  const trimmed = slice.trimStart();
  const blockStart = style.block?.start ?? null;
  const linePrefix = style.linePrefixes.find((prefix) =>
    trimmed.startsWith(prefix)
  );
  if (!linePrefix && !(blockStart && trimmed.startsWith(blockStart))) {
    return null;
  }

  const startIndex = offset + (slice.length - trimmed.length);
  if (blockStart && trimmed.startsWith(blockStart)) {
    const endIndex = content.indexOf(style.block!.end, startIndex + 2);
    if (endIndex === -1) {
      return { text: '', error: 'unterminated block comment' };
    }
    const raw = content.slice(startIndex + 2, endIndex);
    const lines = normalizeCommentLines(raw, '', true);
    return { text: lines.join('\n') };
  }

  const lines: string[] = [];
  const allLines = content.slice(startIndex).split(/\r?\n/);
  for (const line of allLines) {
    const trimmedLine = line.trim();
    if (linePrefix && trimmedLine.startsWith(linePrefix)) {
      lines.push(normalizeCommentLines(line, linePrefix, false)[0] ?? '');
      continue;
    }
    if (trimmedLine === '') {
      lines.push('');
      continue;
    }
    break;
  }
  return { text: lines.join('\n') };
}

function parseInlineArray(value: string): string[] {
  try {
    const parsed = JSON.parse(value.replace(/'/g, '"')) as unknown;
    if (Array.isArray(parsed)) {
      return parsed.map((item) => String(item).trim()).filter(Boolean);
    }
  } catch {
    return [];
  }
  return [];
}

function normalizeValue(raw: string): string {
  const trimmed = raw.trim();
  return trimmed.replace(/^['"]|['"]$/g, '').trim();
}

function parseFrontMatter(text: string): {
  data: FrontMatter;
  error?: string;
} | null {
  const lines = text.split(/\r?\n/);
  const startIndex = lines.findIndex((line) => line.trim() === '---');
  if (startIndex === -1) {
    return null;
  }
  const endIndex = lines.findIndex(
    (line, index) => index > startIndex && line.trim() === '---'
  );
  if (endIndex === -1) {
    return { data: {}, error: 'unterminated front matter' };
  }

  const data: FrontMatter = {};
  let collectingReadWhen = false;

  for (const rawLine of lines.slice(startIndex + 1, endIndex)) {
    const line = rawLine.trim();
    if (!line || line.startsWith('#')) {
      continue;
    }

    const keyMatch = line.match(/^([A-Za-z0-9_.-]+):\s*(.*)$/);
    if (keyMatch) {
      const [, key, rest] = keyMatch;
      collectingReadWhen = false;
      if (key === 'summary') {
        if (rest !== '') {
          data.summary = normalizeValue(rest);
        }
        continue;
      }
      if (key === 'read-when') {
        if (rest === '') {
          data.readWhen = [];
          collectingReadWhen = true;
          continue;
        }
        if (rest.startsWith('[') && rest.endsWith(']')) {
          data.readWhen = parseInlineArray(rest);
          continue;
        }
        data.readWhen = [normalizeValue(rest)].filter(Boolean);
        continue;
      }
      continue;
    }

    if (collectingReadWhen && line.startsWith('- ')) {
      const value = normalizeValue(line.slice(2));
      if (!data.readWhen) {
        data.readWhen = [];
      }
      if (value) {
        data.readWhen.push(value);
      }
    }
  }

  if (!data.summary && (!data.readWhen || data.readWhen.length === 0)) {
    return { data: {} };
  }
  return { data };
}

function walkSourceFiles(
  root: string,
  extensions: Set<string>
): { entries: Entry[] } {
  const entries: Entry[] = [];

  function walk(dir: string) {
    for (const entry of Deno.readDirSync(dir)) {
      if (entry.name.startsWith('.')) {
        continue;
      }
      if (entry.isDirectory) {
        if (EXCLUDED_DIRS.has(entry.name)) {
          continue;
        }
        walk(join(dir, entry.name));
        continue;
      }
      if (!entry.isFile) {
        continue;
      }

      const extIndex = entry.name.lastIndexOf('.');
      const ext = extIndex === -1 ? '' : entry.name.slice(extIndex);
      if (!extensions.has(ext)) {
        continue;
      }

      const fullPath = join(dir, entry.name);
      const content = Deno.readTextFileSync(fullPath);
      const style = getCommentStyle(ext);
      const comment = extractTopLevelComment(content, style);
      let data: FrontMatter = {};
      let error: string | undefined;
      if (!comment) {
        // No top-level comment; still include file with empty metadata.
      } else if (comment.error) {
        error = comment.error;
      } else {
        const frontMatter = parseFrontMatter(comment.text);
        if (!frontMatter) {
          // No front matter block; keep empty metadata.
        } else {
          if (frontMatter.error) {
            error = frontMatter.error;
          }
          data = frontMatter.data;
        }
      }
      entries.push({
        relativePath: relative(root, fullPath),
        data,
        error,
      });
    }
  }

  walk(root);
  return { entries };
}

function buildTree(entries: Entry[]): TreeNode {
  const root: TreeNode = { kind: 'dir', name: '.', children: [] };

  for (const entry of entries) {
    const parts = entry.relativePath.split(/[\\/]/);
    let current = root;
    for (let i = 0; i < parts.length; i += 1) {
      const name = parts[i];
      const isFile = i === parts.length - 1;
      if (isFile) {
        current.children.push({ kind: 'file', name, entry });
        break;
      }
      let next = current.children.find(
        (child): child is TreeNode =>
          child.kind === 'dir' && child.name === name
      );
      if (!next || next.kind !== 'dir') {
        next = { kind: 'dir', name, children: [] };
        current.children.push(next);
      }
      current = next;
    }
  }

  return root;
}

function sortTree(node: TreeNode) {
  if (node.kind === 'dir') {
    node.children.forEach(sortTree);
    node.children.sort((a, b) => {
      if (a.kind !== b.kind) {
        return a.kind === 'dir' ? -1 : 1;
      }
      return a.name.localeCompare(b.name);
    });
  }
}

function formatFileLabel(entry: Entry): string {
  const summary = entry.data.summary ? ` - ${entry.data.summary}` : '';
  const readWhen =
    entry.data.readWhen && entry.data.readWhen.length > 0
      ? ` [read-when: ${entry.data.readWhen.join('; ')}]`
      : '';
  const error = entry.error ? ` [error: ${entry.error}]` : '';
  return `${entry.relativePath}${summary}${readWhen}${error}`;
}

function renderTree(node: TreeNode, prefix: string, isLast: boolean): string[] {
  const lines: string[] = [];
  if (node.kind === 'dir') {
    const label = node.name === '.' ? node.name : node.name;
    if (prefix === '') {
      lines.push(label);
    } else {
      lines.push(`${prefix}${isLast ? '`-' : '|-'} ${label}`);
    }
    const childPrefix = prefix + (isLast ? '   ' : '|  ');
    node.children.forEach((child, index) => {
      const last = index === node.children.length - 1;
      lines.push(...renderTree(child, childPrefix, last));
    });
  } else {
    lines.push(`${prefix}${isLast ? '`-' : '|-'} ${formatFileLabel(node.entry)}`);
  }
  return lines;
}

const options = parseArgs(Deno.args);
const { entries } = walkSourceFiles(
  options.root,
  options.extensions
);

if (entries.length === 0) {
  console.log('No matching front matter comments found.');
  Deno.exit(0);
}

const tree = buildTree(entries);
sortTree(tree);

const lines = renderTree(tree, '', true);
console.log(lines.join('\n'));
