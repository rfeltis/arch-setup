# arch-setup

Bootstrap a fresh Arch install:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/rfeltis/arch-setup/main/bootstrap.sh)
```

NVIDIA graphics cards are detected automatically using their PCI vendor and
display class IDs, including on systems with multiple GPUs. When one is present,
Ansible installs `nvidia-open-dkms`, `nvidia-utils`, `lib32-nvidia-utils` (for Steam),
and `nvidia-settings`. Systems without an NVIDIA GPU skip these packages.

Sunshine (the Moonlight host) is installed from the AUR only when the hostname
is `livingroom`. Other machines skip it.

A **Gamescope (Steam)** session is added to the login screen. It runs Steam Big
Picture inside Gamescope, and the session ends (returning to the login screen)
when Steam fully quits. The launch options live in
`gamescope/gamescope-session`.

AUR packages are installed with `paru-bin`, the prebuilt version of paru, so no
Rust build is needed.

The open kernel modules require a Turing or newer NVIDIA GPU. Older cards need
a legacy driver instead and are not supported by this setup. DKMS uses the
`linux-headers` installed by the playbook (and `linux-surface-headers` on Surface
hardware); any additional kernels need their matching headers installed as well.
Reboot after the first driver installation to load the NVIDIA modules.

## SSH key on the YubiKey

On the hosts in `yubikey_ssh_hosts` (stryketopia), SSH logins use a key stored
on the YubiKey: logging in needs a touch, and no password. Create it once:

```bash
ssh-keygen -t ed25519-sk -O resident -C yubikey -f ~/.ssh/id_ed25519_sk
ssh-copy-id -i ~/.ssh/id_ed25519_sk.pub <server>
```

`~/.ssh/id_ed25519_sk` is only a handle that tells the YubiKey which key to use,
and the YubiKey keeps a copy of it (`-O resident`). After a reinstall, the
playbook notices the file is missing and asks for the YubiKey's FIDO2 PIN to
download it again. Leave the PIN empty to skip, and run
`./apply.sh --tags ssh-key` later (it asks for the sudo password first; just press
Enter, since this step doesn't need it). This runs at the end of the playbook, and
if the download fails, the playbook says why and still finishes successfully, so
`bootstrap.sh` carries on with its GitHub setup.

Each run tries the PIN once. After 3 wrong PINs in a row, unplug the YubiKey and
plug it back in; after 8, it locks its FIDO2 part. The restored `.pub` file has
`ssh:` as its comment instead of `yubikey`, but it's the same key: compare
fingerprints with `ssh-keygen -lf ~/.ssh/id_ed25519_sk.pub`.
