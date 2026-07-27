# Fix: APT local-repo fallback to internet when NAS unavailable

## Problem

When `main.sh` runs, `local-repo.sh` configures APT to use a local package
repository hosted on a NAS server (priority 900). If the NAS becomes
unavailable, APT should fall back to internet mirrors. This failed in two
ways:

1. **Stale CIFS mounts**: `mount.sh` used `mountpoint -q` to check NAS
   availability, which only queries the kernel mount table. If the NAS went
   offline without a clean unmount, the mount point still existed, so
   `NAS_MOUNTED` was set to `true` and the stale local repo files were never
   cleaned up.

2. **No cleanup on exit**: If `main.sh` failed midway or exited for any
   reason, the local repo `.list` and pin files persisted. On subsequent
   `apt` operations, APT would try to reach the dead `file://` path and
   hang or error.

## Changes

### `os-provision/commands/mount.sh`

After `mountpoint -q` succeeds, verify the mount is actually responsive
with `timeout 3 stat "$TARGET_DIR"`. If it fails, `NAS_MOUNTED` stays
`false` so downstream scripts treat NAS as unavailable.

```bash
if mountpoint -q "$MOUNT_POINT" 2>/dev/null; then
    if timeout 3 stat "$TARGET_DIR" >/dev/null 2>&1; then
        NAS_MOUNTED=true
    else
        echo "WARNING: NAS mount stale (server unreachable), treating as unavailable"
    fi
elif sudo mount -t cifs ...; then
    ...
```

### `os-provision/main.sh`

Added `trap cleanup_local_repo EXIT` after the `local-repo.sh` call. The
trap removes `debtorchy-local.list` and `debtorchy-local` pin file only
when `NAS_MOUNTED != "true"`, then runs `apt-get update` to refresh.

```bash
cleanup_local_repo() {
    if [ "$NAS_MOUNTED" != "true" ]; then
        local local_repo_list="/etc/apt/sources.list.d/debtorchy-local.list"
        local local_repo_pin="/etc/apt/preferences.d/debtorchy-local"
        if [ -f "$local_repo_list" ]; then
            sudo rm -f "$local_repo_list" "$local_repo_pin"
            sudo apt-get update -qq 2>/dev/null || true
        fi
    fi
}
trap cleanup_local_repo EXIT
```

### `os-provision/commands/local-repo.sh` (prior commit)

Already fixed: cleans up stale files when `NAS_MOUNTED != "true"` at the
start of each run. The `mount.sh` and `main.sh` fixes above close the
remaining gaps.

## Defense layers

| Layer | When it runs | What it catches |
|-------|-------------|-----------------|
| `local-repo.sh` cleanup | Start of each run | NAS was down before this run started |
| `mount.sh` stat check | During mount detection | Stale CIFS mount (server unreachable but kernel mount exists) |
| `main.sh` trap EXIT | On any exit (success/failure/SIGINT) | Script failed midway or NAS went down mid-run |
