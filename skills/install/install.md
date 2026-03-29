---
name: install
description: Install git-zhi and create companion symlinks — downloads the correct binary for the current platform from GitHub releases
---

<!-- ABOUTME: Skill for installing git-zhi binary and seeding the plugin manifest under ~/.claude/crochet/. -->
<!-- ABOUTME: Downloads the correct platform binary, verifies installation, and writes a JSON manifest of detected plugins. -->

# crochet:install

Installs git-zhi if it is not already on `$PATH`. Downloads the correct
binary for the current platform from GitHub releases and creates companion
symlinks.

## Trigger

User says "install git-zhi", "set up git-zhi", or any crochet skill fails
because git-zhi is not found.

## Process

### Step 1: Check if git-zhi is already installed

```bash
which git-zhi
```

If found, report the version (`git zhi version`) and exit.

### Step 2: Confirm installation

Tell the user:

> git-zhi is not installed. I can install it by downloading the binary from
> GitHub. It will be placed in `~/.local/bin/` and companion symlinks will
> be created for all plugin commands.
>
> Install now?

Wait for confirmation.

### Step 3: Run the installer

```bash
curl -fsSL https://raw.githubusercontent.com/perigrin/git-zhi/pu/install.sh | sh
```

If `~/.local/bin` is not on `$PATH`, tell the user how to add it.

### Step 4: Verify

```bash
git zhi version
git zhi setup  # ensure all companion symlinks exist
```

Report success and the installed version.

### Step 5: Seed capabilities manifest

Create the `.claude/crochet/` directory if it does not exist:

```bash
mkdir -p ~/.claude/crochet/
```

Scan the following directories for installed skills and plugins:

- `~/.claude/skills/` — superpowers skills
- `~/.claude/plugins/marketplaces/paad/plugins/paad/skills/` — paad skills
- `~/.claude/plugins/cache/superpowers-marketplace/` — superpowers marketplace cache

For each scan path, check whether the directory exists. If it exists, list the
skill names found inside it (subdirectory names or `*.md` file stems). If it
does not exist, record `"installed": false` for that plugin source.

Build a capabilities JSON object of the form:

```json
{
  "superpowers": {
    "installed": true,
    "skills": ["skill-name", "..."]
  },
  "paad": {
    "installed": false
  },
  "superpowers_cache": {
    "installed": true,
    "skills": ["skill-name", "..."]
  }
}
```

Write the result to `~/.claude/crochet/capabilities.json`.

Report how many capabilities were found across all sources.

## Key Constraints

- Always ask before downloading and executing anything.
- Always use the binary download via `install.sh` first. It is faster and does
  not require a Go toolchain.
- Only fall back to `go install github.com/perigrin/git-zhi@latest && git zhi setup`
  if the binary download fails (network error, unsupported platform, curl not
  available) or if the user explicitly asks to build from source.
- Do NOT offer `go build` as an alternative just because `go` is on `$PATH`.
- If the install fails, show the error and suggest manual installation from
  https://github.com/perigrin/git-zhi/releases
