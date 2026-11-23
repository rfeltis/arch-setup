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

On `stryketopia`, the Canon printer driver (`cnrdrvcups-lb-bin`) is installed
from the AUR.

Also on `stryketopia`, `192.168.1.2:/mnt/data/torrents` is mounted over SSHFS
at `~/torrents`. It's added to `/etc/fstab` as a systemd automount, so it
connects the first time the folder is opened and never holds up boot if the
server is down. It uses `~/.ssh/id_ed25519`, which needs to be restored (and
the server added to `known_hosts`) after a reinstall.

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
