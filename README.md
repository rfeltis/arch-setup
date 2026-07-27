# arch-setup

Bootstrap a fresh Arch install:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/rfeltis/arch-setup/main/bootstrap.sh)
```

> Use `bash <(curl ...)` rather than `curl ... | bash` — piping consumes stdin,
> which breaks the sudo, Ansible and GitHub login prompts.
