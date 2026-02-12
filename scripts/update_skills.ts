#!/usr/bin/env -S deno run -qA

import { parseArgs } from "jsr:@std/cli@1.0.27";
import { parse as parseToml } from "jsr:@std/toml@1.0.11";
import { join, resolve } from "jsr:@std/path@1.1.4";

type SkillMap = Record<string, string>;

const DEFAULT_FILE = "skills/sources.toml";
const DEFAULT_DEST = "skills";

function usage(): string {
  return [
    "Usage: ./scripts/update_skills.ts [--file <toml>] [--dest <dir>] [--overwrite] [--dry-run]",
    "",
    "TOML format:",
    "[skills]",
    'imagegen = "https://github.com/openai/skills/tree/main/skills/.curated/imagegen"',
  ].join("\n");
}

function parseCliArgs(args: string[]) {
  const parsed = parseArgs(args, {
    boolean: ["dry-run", "overwrite", "help"],
    string: ["file", "dest"],
    alias: { h: "help" },
    default: { file: DEFAULT_FILE, dest: DEFAULT_DEST },
  });

  if (parsed.help) {
    console.log(usage());
    Deno.exit(0);
  }

  const file = parsed.file;
  const dest = parsed.dest;
  if (!file || !dest) throw new Error(`Missing --file or --dest\n\n${usage()}`);

  return {
    file,
    dest,
    overwrite: Boolean(parsed.overwrite),
    dryRun: Boolean(parsed["dry-run"]),
  };
}

function readSkillMap(tomlText: string): SkillMap {
  const parsed = parseToml(tomlText);
  const skills = (parsed as Record<string, unknown>).skills;
  if (!skills || typeof skills !== "object") {
    throw new Error("Missing [skills] table in TOML.");
  }

  const map: SkillMap = {};
  for (
    const [key, value] of Object.entries(
      skills as Record<string, unknown>,
    )
  ) {
    if (typeof value !== "string") {
      throw new Error(`Skill '${key}' must map to a string URL.`);
    }
    map[key] = value;
  }
  return map;
}

function getInstallerPath(): string {
  const home = Deno.env.get("HOME");
  if (!home) throw new Error("HOME not set.");
  return join(
    home,
    ".codex/skills/.system/skill-installer/scripts/install-skill-from-github.py",
  );
}

async function pathExists(path: string): Promise<boolean> {
  try {
    await Deno.stat(path);
    return true;
  } catch {
    return false;
  }
}

async function main() {
  const { file, dest, overwrite, dryRun } = parseCliArgs(Deno.args);
  const tomlText = await Deno.readTextFile(file);
  const skills = readSkillMap(tomlText);
  const installer = getInstallerPath();
  const destDir = resolve(dest);

  if (!(await pathExists(installer))) {
    throw new Error(`Missing installer script: ${installer}`);
  }

  const entries = Object.entries(skills).sort(([a], [b]) => a.localeCompare(b));
  if (entries.length === 0) {
    console.log("No skills listed.");
    return;
  }

  const failures: Array<{ name: string; reason: string }> = [];
  let successCount = 0;

  for (const [name, url] of entries) {
    let backupDir: string | null = null;
    const skillDir = join(destDir, name);

    try {
      if (await pathExists(skillDir)) {
        if (!overwrite) {
          throw new Error(
            `Skill exists: ${skillDir}. Use --overwrite to replace.`,
          );
        }
        if (!dryRun) {
          backupDir = join(destDir, `.update-skills-backup-${name}-${crypto.randomUUID()}`);
          await Deno.rename(skillDir, backupDir);
        }
      }

      const args = [
        "-u",
        installer,
        "--url",
        url,
        "--dest",
        destDir,
        "--name",
        name,
      ];

      if (dryRun) {
        console.log(["python3", ...args].join(" "));
        successCount += 1;
        continue;
      }

      const cmd = new Deno.Command("python3", {
        args,
        stdin: "null",
        stdout: "inherit",
        stderr: "inherit",
      });
      const { code } = await cmd.output();
      if (code !== 0) {
        throw new Error(`Installer exited with code ${code}.`);
      }

      if (backupDir && await pathExists(backupDir)) {
        await Deno.remove(backupDir, { recursive: true });
      }
      successCount += 1;
    } catch (error) {
      const reason = error instanceof Error ? error.message : String(error);
      failures.push({ name, reason });
      console.error(`Failed '${name}': ${reason}`);

      if (!dryRun && backupDir && await pathExists(backupDir)) {
        try {
          if (await pathExists(skillDir)) {
            await Deno.remove(skillDir, { recursive: true });
          }
          await Deno.rename(backupDir, skillDir);
        } catch (restoreError) {
          const restoreReason = restoreError instanceof Error
            ? restoreError.message
            : String(restoreError);
          console.error(`Restore failed '${name}': ${restoreReason}`);
        }
      }
    }
  }

  console.log(`Updated skills: ${successCount}/${entries.length}`);
  if (failures.length > 0) {
    console.error("Failed skills:");
    for (const failure of failures) {
      console.error(`- ${failure.name}: ${failure.reason}`);
    }
    Deno.exit(1);
  }
}

await main();
