package com.panda.rtk_bluetooth.bean;

public class DeviceInfo {
    public String name;
    public String address;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public DeviceInfo(String name, String address) {
        this.name = name;
        this.address = address;
    }
}
