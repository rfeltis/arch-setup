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

The open kernel modules require a Turing or newer NVIDIA GPU. Older cards need
a legacy driver instead and are not supported by this setup. DKMS uses the
`linux-headers` installed by the playbook (and `linux-surface-headers` on Surface
hardware); any additional kernels need their matching headers installed as well.
Reboot after the first driver installation to load the NVIDIA modules.
