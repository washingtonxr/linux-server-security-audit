# Linux Security Audit & Script Documentation

## 1. The Purpose of a Linux Security Audit
A Linux security audit is a systematic evaluation of a system's configuration, logs, and state to ensure it adheres to security best practices. For an Ubuntu server, regular auditing is critical for:

* **Threat Detection:** Identifying unauthorized login attempts or active brute-force attacks.
* **Vulnerability Management:** Ensuring the kernel and packages are patched against known exploits.
* **Privilege Verification:** Confirming that only authorized users have root-level (`UID 0`) access.
* **Surface Area Reduction:** Monitoring open ports to ensure no unnecessary services are exposed to the public internet.
* **Resource Integrity:** Checking disk and memory to ensure the system isn't being bogged down by rogue processes or log overflows.



---

## 2. Technical Breakdown of `security_check_ubuntu.sh`

The `security_check_ubuntu.sh` script is a lightweight bash utility designed to provide an immediate "health check" of an Ubuntu system. Below is a detailed explanation of each module within the script:

### A. SSH Configuration (`/etc/ssh/sshd_config`)
The script greps for `PermitRootLogin` and `PasswordAuthentication`. 
* **Goal:** Secure servers should ideally have `PermitRootLogin prohibit-password` and `PasswordAuthentication no` (forcing SSH Key usage).

### B. Network & Ports (`ss -tulpn`)
It lists all listening sockets. 
* **Goal:** To ensure that services like MySQL (`3306`) or Redis (`6379`) are not listening on `0.0.0.0` (public) unless specifically required.

### C. Brute Force Analysis (`auth.log`)
By parsing `Failed password` entries, the script highlights recent IP addresses attempting to guess credentials. If this list is long, it indicates the server is a target and may need stricter Firewall rules.

### D. Identity & Privilege Audit (`UID 0`)
The script scans `/etc/passwd` for any user with a User ID of `0`. 
* **Why:** Aside from `root`, no other account should typically have UID 0. An unknown account here is a major red flag for a system compromise.

### E. Package & Update Status (`apt list`)
It calculates the number of pending security updates.
* **Goal:** Keeping the system updated is the #1 defense against "1-day" exploits.

### F. Intrusion Prevention (`Fail2Ban` & `UFW`)
The script verifies if the Uncomplicated Firewall (UFW) and Fail2Ban are active. These tools act as the first line of defense by automatically banning IPs that show malicious behavior.

---

## 3. Usage Instructions

1.  **Permission:** Ensure the script has execution rights:
    ```bash
    chmod +x security_check.sh
    ```
2.  **Execution:** Run with `sudo` to ensure the script can read protected log files (`/var/log/auth.log`) and system configurations:
    ```bash
    sudo ./security_check.sh
    ```

---

**Author:** Washington Ruan  
**Date:** February 25, 2026  
**License:** MIT
