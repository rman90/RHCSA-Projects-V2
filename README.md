# 📚 RHCSA Projects

This repository contains a curated set of hands‑on projects and study notes to prepare for the **Red Hat Certified System Administrator (RHCSA)** exam.  Each numbered directory maps to a major exam objective and contains a `README.md` explaining the concepts, along with one or more scripts or lab guides you can run to practice the topic.

## Modules overview

| Module | Description |
|------:|-------------|
| 01    | Getting started with Linux – basic shell navigation, understanding the filesystem hierarchy and essential commands. |
| 02    | User and group management – creating accounts, using sudo, password policies and batch user creation. |
| 03    | Permissions and ACLs – managing ownership, traditional UNIX permissions, sticky/SUID/SGID bits, ACLs and extended attributes. |
| 04    | Storage management – disk partitioning, filesystems, `fstab` and introductory LVM. |
| 05    | Systemd services – managing units, targets, journald and writing your own services. |
| 06    | Networking – configuring IPv4/IPv6 addresses, `nmcli`, DNS and hostnames. |
| 07    | Routing and NAT – adding static routes, VLANs and configuring NAT/firewalld. |
| 08    | Process management – job control, priorities with `nice`/`renice`, signals and top. |
| 09    | Scheduling tasks – cron, at, systemd timers and cron environment variables. |
| 10    | Advanced storage – LVM in depth, extending volumes, snapshots and removing devices. |
| 11    | Boot process – understanding POST→GRUB→kernel→initramfs→systemd, troubleshooting and password recovery. |
| 12    | Container management – working with Podman, rootless containers and building images. |
| 13    | Repository management – installing software with RPM/DNF and creating local repositories. |
| 14    | Troubleshooting skills – SELinux modes/contexts, journal analysis, recovery targets and rescue disks. |
| 15    | Logging and monitoring – persistent journals, rsyslog filtering, log rotation and system health monitoring. |
| 16    | Networking services – configuring SSH, Apache HTTPD, NFS and automount for network storage. |
| 17    | DNS and SSH keys – setting up DNS resolution and secure SSH key‑based authentication. |
| 18    | Managing containers – running containers with Podman, working with pods and orchestrating with systemd. |
| 19    | Container images and storage – building custom images with a Containerfile and persisting data with volumes. |
| 20    | Software management – RPM/DNF basics, AppStream module streams and creating local repositories. |
| 21    | Troubleshooting boot – breaking into the initramfs, systemd emergency/rescue targets, dracut and fstab repair. |

Each module’s README includes a **Useful Commands** section, example usage and practice exercises.  Scripts are intended to be run with superuser privileges in a test environment; **never run them on production machines**.

To get started, clone the repository, pick a module and follow the steps in its README.  Feel free to customise or extend the projects to fit your own learning style.
