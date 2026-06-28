# Dockerized Dev Environment

A personal Arch Linux dev container with Neovim, Yazi, Starship, and more.
Passwords are set using Docker BuildKit secrets so they are never stored in image layers or visible in `docker history`.

---

## Project Structure

```
.
├── Dockerfile
├── .dockerignore
├── .bashrc
├── .fonts/
├── yazi/
├── starship/
├── nvim/
└── secrets/  
    ├── user_pass
    └── root_pass
```

---

## Why BuildKit Secrets

Standard `ARG` or `ENV` passwords are visible in `docker history` — anyone who pulls the image can read them. BuildKit secrets are mounted at build time in a tmpfs at `/run/secrets/` and are never written to any image layer, making it safe to push to a public registry.

---

## Prerequisites

BuildKit is included in Docker Engine 23.0+ and enabled by default. Verify with:

```bash
docker buildx version
```

---

## Setup

### 1. Clone the repository

```bash
git clone https://github.com/0xlichi/dockerized-dev.git
cd dockerized-dev
```

### 2. Create the secrets directory

```bash
mkdir secrets
echo "yourUserPassword" > secrets/user_pass
echo "yourRootPassword" > secrets/root_pass
```

> The `secrets/` directory is listed in both `.gitignore` and `.dockerignore`. Never commit it.

---

## Build

```bash
DOCKER_BUILDKIT=1 docker build \
  --secret id=user_pass,src=secrets/user_pass \
  --secret id=root_pass,src=secrets/root_pass \
  -t 0xlichi/dev:latest .
```

### Verify no passwords leaked

```bash
docker history 0xlichi/dev:latest
```

The secret layer will appear as a generic `RUN` entry with no values exposed.

---

## Run

Basic:

```bash
docker run -it --name mydev 0xlichi/dev
```

With a persistent workspace (recommended):

```bash
docker run -it \
  --name mydev \
  -v "$HOME/projects:/home/apple/projects" \
  0xlichi/dev
```

---

## Password Usage

The container drops you directly into a bash shell as `apple`. Passwords are used only for privilege escalation.

| Action | Command | Prompts for |
|---|---|---|
| Run a privileged command | `sudo <command>` | apple's password |
| Switch to root shell | `su - root` | root's password |
| Install packages | `sudo pacman -Syu` | apple's password |

---

## Rebuilding

Changing dotfiles (Neovim config, `.bashrc`, etc.) without touching packages will reuse the cached package layer and only rebuild from the `COPY` steps.

Force a full rebuild with:

```bash
DOCKER_BUILDKIT=1 docker build --no-cache \
  --secret id=user_pass,src=secrets/user_pass \
  --secret id=root_pass,src=secrets/root_pass \
  -t 0xlichi/dev:latest .
```

---

## Included Tools

| Tool | Purpose |
|---|---|
| neovim | Primary editor |
| lazygit | Git TUI |
| yazi | Terminal file manager |
| starship | Shell prompt |
| zoxide | Smarter cd |
| fzf | Fuzzy finder |
| bat | Better cat |
| trash-cli | Safe delete |

---

## Notes

- Default user: `apple` (UID/GID `1000`)
- Shell: `/bin/bash`
- Base image: `archlinux:latest`
- Fonts, Yazi, Starship, and Neovim configs are copied from the host at build time
---
