package main

import (
	"encoding/json"
	"fmt"
	"os"
	"github.com/muaimingjun/LinuxCTS/monitor/network"
	"github.com/muaimingjun/LinuxCTS/monitor/sysinfo"
	"github.com/shirou/gopsutil/v3/cpu"
	"github.com/shirou/gopsutil/v3/host"
	"github.com/shirou/gopsutil/v3/mem"
)
// DeviceInfo 定义了我们要抓取的详细字段
type DeviceInfo struct {
	HostName        string `json:"hostname"`
	OS              string `json:"os"`
	Platform        string `json:"platform"` // 例如: ubuntu, centos
	PlatformVersion string `json:"platform_version,omitempty"`
	KernelVersion   string `json:"kernel_version"`
	Uptime          uint64 `json:"uptime_seconds"`
	CPUModel        string `json:"cpu_model"`
	CPUCores        int    `json:"cpu_cores"`
	NetworkInterfaces []network.IPInfo `json:"network_interfaces,omitempty"`
	GPUs            []sysinfo.GPUInfo `json:"gpus,omitempty"`
	TotalMemory     uint64 `json:"total_memory_gb"`
	MacAddress      string `json:"mac_address"`
}

func main() {
	// 1. 获取主机基础信息 (系统、内核、运行时间)
	hInfo, _ := host.Info()

	// 2. 获取 CPU 详细规格
	cInfo, _ := cpu.Info()
	cpuModel := "Unknown"
	if len(cInfo) > 0 {
		cpuModel = cInfo[0].ModelName
	}

	// 3. 获取内存总量
	vMode, _ := mem.VirtualMemory()
	macAddr := network.GetPrimaryMac()
	ipList, _ := network.GetIPDetails()
	gpuList, _ := sysinfo.GetGPUInfo()

	// 5. 组装数据结构
	device := DeviceInfo{
		HostName:      hInfo.Hostname,
		OS:            hInfo.OS,
		Platform:      hInfo.Platform,
		PlatformVersion: hInfo.PlatformVersion,
		KernelVersion: hInfo.KernelVersion,
		Uptime:        hInfo.Uptime,
		CPUModel:      cpuModel,
		CPUCores:      len(cInfo),
		NetworkInterfaces: ipList,
		GPUs:            gpuList,
		TotalMemory:   vMode.Total / 1024 / 1024 / 1024, // 转为 GB
		MacAddress:    macAddr,
	}

	// 6. 打印并保存
	result, _ := json.MarshalIndent(device, "", "  ")
	fmt.Println(string(result))
	
	_ = os.WriteFile("device_detail.json", result, 0644)
	fmt.Println("\n✅ 设备详细信息已写入 device_detail.json")
}