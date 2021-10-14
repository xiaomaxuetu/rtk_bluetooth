package com.panda.rtk_bluetooth.bean;

public class InitResultInfo {
    private String message;
    private boolean isSuccess;

    public String getMessage() {
        return message;
    }

    public boolean isSuccess() {
        return isSuccess;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public void setSuccess(boolean success) {
        isSuccess = success;
    }
}
