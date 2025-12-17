package sysinfo

import (
    "bufio"
    "bytes"
    "os"
    "os/exec"
    "regexp"
    "strings"
)

// GPUInfo 描述检测到的显卡和驱动信息
type GPUInfo struct {
    PCI           string `json:"pci,omitempty"`
    Class         string `json:"class,omitempty"`
    Vendor        string `json:"vendor,omitempty"`
    Model         string `json:"model,omitempty"`
    KernelDriver  string `json:"kernel_driver,omitempty"`
    DriverPresent bool   `json:"driver_present"`
    NvidiaSmi     string `json:"nvidia_smi,omitempty"`
    HasDRM        bool   `json:"has_drm_device"`
}

// GetGPUInfo 尝试使用 lspci、nvidia-smi、lsmod 和 /dev/dri 等信息来判断显卡与驱动
func GetGPUInfo() ([]GPUInfo, error) {
    var out []GPUInfo
    // Prefer machine-readable lspci (-mm) to extract vendor and device cleanly
    lspciPath, _ := exec.LookPath("lspci")
    if lspciPath != "" {
        // -mm prints fields in quotes: "slot" "class" "vendor" "device" ...
        b, _ := exec.Command(lspciPath, "-mm").CombinedOutput()
        lines := strings.Split(string(b), "\n")
        quoteRe := regexp.MustCompile(`"([^"]*)"`)
        for _, line := range lines {
            if strings.TrimSpace(line) == "" {
                continue
            }
            // only consider VGA/3D/Display classes appearing in the class field
            matches := quoteRe.FindAllStringSubmatch(line, -1)
            if len(matches) >= 4 {
                slot := matches[0][1]
                class := matches[1][1]
                vendor := matches[2][1]
                device := matches[3][1]
                lclass := strings.ToLower(class)
                if strings.Contains(lclass, "vga") || strings.Contains(lclass, "3d") || strings.Contains(lclass, "display") {
                    gi := GPUInfo{PCI: slot, Class: class, Vendor: vendor, Model: device}
                    // query kernel driver for this slot
                    if b2, err := exec.Command(lspciPath, "-k", "-s", slot).CombinedOutput(); err == nil {
                        s2 := string(b2)
                        for _, l := range strings.Split(s2, "\n") {
                            l = strings.TrimSpace(l)
                            if strings.HasPrefix(l, "Kernel driver in use:") {
                                gi.KernelDriver = strings.TrimSpace(strings.TrimPrefix(l, "Kernel driver in use:"))
                                gi.DriverPresent = gi.KernelDriver != ""
                            }
                        }
                    }
                    out = append(out, gi)
                }
            }
        }
    }

    // Fallback: if machine-readable parsing didn't find GPUs, try original -nnk text parsing
    if len(out) == 0 && lspciPath != "" {
        if b, _ := exec.Command(lspciPath, "-nnk").CombinedOutput(); b != nil {
            text := string(b)
            lines := strings.Split(text, "\n")
            hdrRe := regexp.MustCompile(`(?i)\b(vga|3d|display)\b`)
            pciRe := regexp.MustCompile(`^([0-9a-fA-F:.]+)\s+(.*)$`)
            for i, line := range lines {
                if hdrRe.MatchString(line) {
                    pci := ""
                    if m := pciRe.FindStringSubmatch(line); len(m) >= 3 {
                        pci = m[1]
                    }
                    // try to extract vendor/model from part after ": " and before last "["
                    model := strings.TrimSpace(line)
                    if idx := strings.LastIndex(line, "["); idx > 0 {
                        // take substring after "]: " if present
                        if p := strings.Index(line, "]: "); p >= 0 && p < idx {
                            model = strings.TrimSpace(line[p+3 : idx])
                        }
                    }
                    gi := GPUInfo{PCI: pci, Model: model}
                    for j := i + 1; j < i+6 && j < len(lines); j++ {
                        l := strings.TrimSpace(lines[j])
                        if strings.HasPrefix(l, "Kernel driver in use:") {
                            gi.KernelDriver = strings.TrimSpace(strings.TrimPrefix(l, "Kernel driver in use:"))
                            gi.DriverPresent = gi.KernelDriver != ""
                        }
                    }
                    out = append(out, gi)
                }
            }
        }
    }

    // 2) nvidia-smi (if available)
    if p, _ := exec.LookPath("nvidia-smi"); p != "" {
        if b, err := exec.Command(p, "--query-gpu=name,driver_version", "--format=csv,noheader").CombinedOutput(); err == nil {
            s := strings.TrimSpace(string(b))
            if s != "" {
                if len(out) == 0 { out = append(out, GPUInfo{}) }
                out[0].NvidiaSmi = s
                out[0].DriverPresent = true
            }
        }
    }

    // 3) /proc/driver/nvidia/version
    if _, err := os.Stat("/proc/driver/nvidia/version"); err == nil {
        if len(out) == 0 {
            out = append(out, GPUInfo{})
        }
        out[0].DriverPresent = true
    }

    // 4) lsmod check for common modules
    if b, err := exec.Command("/bin/sh", "-c", "lsmod | egrep 'nvidia|amdgpu|radeon|i915' || true").CombinedOutput(); err == nil {
        s := strings.TrimSpace(string(b))
        if s != "" {
            if len(out) == 0 { out = append(out, GPUInfo{}) }
            out[0].DriverPresent = true
            scanner := bufio.NewScanner(bytes.NewReader(b))
            if scanner.Scan() {
                mod := strings.Fields(scanner.Text())[0]
                if out[0].KernelDriver == "" {
                    out[0].KernelDriver = mod
                }
            }
        }
    }

    // 5) /dev/dri
    if fi, err := os.Stat("/dev/dri"); err == nil && fi.IsDir() {
        if len(out) == 0 { out = append(out, GPUInfo{}) }
        out[0].HasDRM = true
    }

    return out, nil
}
