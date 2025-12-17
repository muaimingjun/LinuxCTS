package network

import (
    "net"
)

// IPInfo 存储网卡详细信息
type IPInfo struct {
    Interface  string `json:"interface"`
    IP         string `json:"ip"`
    IsLoopback bool   `json:"is_loopback"`
    MAC        string `json:"mac,omitempty"`
}

// GetIPDetails 返回所有 IPv4 地址及所属网卡信息
func GetIPDetails() ([]IPInfo, error) {
    var ips []IPInfo
    interfaces, err := net.Interfaces()
    if err != nil {
        return nil, err
    }

    for _, inter := range interfaces {
        addrs, err := inter.Addrs()
        if err != nil {
            continue
        }
        mac := inter.HardwareAddr.String()
        for _, addr := range addrs {
            ipNet, ok := addr.(*net.IPNet)
            if !ok {
                continue
            }
            // 仅 IPv4
            if ipNet.IP.To4() == nil {
                continue
            }
            ips = append(ips, IPInfo{
                Interface:  inter.Name,
                IP:         ipNet.IP.String(),
                IsLoopback: ipNet.IP.IsLoopback(),
                MAC:        mac,
            })
        }
    }
    return ips, nil
}

// GetPrimaryMac 返回第一个非回环非空的 MAC 地址
func GetPrimaryMac() string {
    interfaces, err := net.Interfaces()
    if err != nil {
        return ""
    }
    for _, inter := range interfaces {
        if inter.Flags&net.FlagLoopback != 0 {
            continue
        }
        if inter.HardwareAddr != nil && inter.HardwareAddr.String() != "" {
            return inter.HardwareAddr.String()
        }
    }
    return ""
}
