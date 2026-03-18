---
name: install
description: Install git-zhi and create companion symlinks — downloads the correct binary for the current platform from GitHub releases
---

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

## Key Constraints

- Always ask before downloading and executing anything.
- If `go` is available and the user prefers building from source, offer that instead:
  `go install github.com/perigrin/git-zhi@latest && git zhi setup`
- If the install fails, show the error and suggest manual installation from
  https://github.com/perigrin/git-zhi/releases
