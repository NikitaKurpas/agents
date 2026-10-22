# agents

Nik's agent skills, configuration, and plugins.

## Plugins

The repository is a plugin marketplace named `nikitakurpas` for both Claude Code and Codex.

| Plugin      | Contents                                                                                                                                                        |
| ----------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `standards` | Engineering principles as skills. `/with-standards` (`$with-standards` in Codex) applies them to the current task and names the ones that shaped each decision. |

### Claude Code

```bash
claude plugin marketplace add NikitaKurpas/agents
claude plugin install standards@nikitakurpas
```

Inside a session, `/plugin marketplace add NikitaKurpas/agents` and `/plugin install standards@nikitakurpas` do the same. To update:

```bash
claude plugin marketplace update nikitakurpas
claude plugin update standards@nikitakurpas
```

### Codex

```bash
codex plugin marketplace add NikitaKurpas/agents
codex plugin add standards@nikitakurpas
```

To update, run `codex plugin marketplace upgrade`, then `codex plugin add standards@nikitakurpas` again.

## License

The `standards` plugin adapts [pstack](https://github.com/cursor/plugins/tree/main/pstack) under its [MIT license](plugins/standards/LICENSE-pstack).
