package com.panda.rtk_bluetooth;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothSocket;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;

import androidx.annotation.NonNull;

import com.google.gson.Gson;
import com.panda.rtk_bluetooth.bean.DeviceInfo;
import com.panda.rtk_bluetooth.bean.InitResultInfo;
import com.panda.rtk_bluetooth.util.JsonUtil;
import com.panda.rtk_bluetooth.util.MapUtil;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.UUID;

import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** RtkBluetoothPlugin */
public class RtkBluetoothPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;

  private String currentMacAddress;
  private Result currentResult;
  private BluetoothSocket mySocket;
  private ConnectThread connectThread;
  private ReceiveDatas receiveDatas;
  private boolean flag = false;
  private String TAG = "BLUE_TOOTH";
  private  MyHandler handler = new MyHandler(this);



  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "rtk_bluetooth");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getBondDevices")) {
      Set<BluetoothDevice> pairedDevices = BluetoothAdapter.getDefaultAdapter().getBondedDevices();
      List<DeviceInfo> devices = new ArrayList<>();
      for (BluetoothDevice device:pairedDevices) {
        DeviceInfo deviceInfo = new DeviceInfo(device.getName(),device.getAddress());
        devices.add(deviceInfo);
      }

      Gson gson = new Gson();
      String string = gson.toJson(devices);
      result.success(string);

    }else if(call.method.equals("connect")){
      currentMacAddress =  call.argument("address");
      flag = false;
      connectThread = new ConnectThread();
      connectThread.start();
      currentResult = result;

    }else if(call.method.equals("close")){
      try {
        flag = true;
        if(connectThread!=null&&connectThread.getState() != Thread.State.TERMINATED){
          connectThread.interrupt();
        }
        if(receiveDatas!=null&&receiveDatas.getState() != Thread.State.TERMINATED){
          receiveDatas.interrupt();
        }
        mySocket.close();
        String  json = JsonUtil.toJson(MapUtil.deepToMap(getResultBean(true,"??????????????????")));
        result.success(json);
      } catch (IOException e) {
        e.printStackTrace();
      }
    }
    else {
      result.notImplemented();
    }
  }
  private InitResultInfo getResultBean(boolean isSuccess, String msg) {
    InitResultInfo bean = new InitResultInfo();
    bean.setSuccess(isSuccess);
    bean.setMessage(msg);
    return bean;
  }
  private class ConnectThread extends Thread {
    @Override
    public void run() {
      BluetoothAdapter adapter = null;
      try {
        //DatabaseHelper.getInstance().insert(new AppLogger("????????????????????????"));
        // 1.// ?????????????????????
        adapter = BluetoothAdapter.getDefaultAdapter();
        // ????????????,???????????????????????????
        if (!adapter.isEnabled()) {
          adapter.enable();
        }

        for (int i = 0; i < 60; i++) {
          if(flag){
            return;
          }
          openSocket(adapter);
          if (mySocket != null) {
            break;
          } else {
            Log.i(TAG,"??????????????????3????????????");
            Thread.sleep(3 * 1000);
          }
        }

        if (mySocket == null) {
          Log.i(TAG,"????????????????????????????????????????????????????????????????????????");
          return;
        }
        //DatabaseHelper.getInstance().insert(new AppLogger("??????????????????"));

        for (int i = 0; i < 60; i++) {
          if(flag){
            return;
          }
          try {
            if (mySocket.isConnected()) {
              // ?????????????????????????????????????????????
              receiveDatas = new ReceiveDatas();
              receiveDatas.start();
              return;
            } else {
              mySocket.connect();
            }
          }catch(IOException ex){
            ex.printStackTrace();
            // socket??????
            openSocket(adapter);
          } catch (Exception ex) {
            ex.printStackTrace();
            Log.i(TAG,"????????????????????????????????????????????????????????????????????????");
            Thread.sleep(3 * 1000);
          }
        }

        if (!mySocket.isConnected()) {
          Log.i(TAG,"????????????????????????????????????GPS????????????????????????????????????");
        }
      } catch (Exception e) {
        e.printStackTrace();
        try {
          if (mySocket != null)
            mySocket.close();
        } catch (IOException ee) {
          ee.printStackTrace();
        }
      }finally {
        // ????????????
        if (adapter != null){
          adapter.cancelDiscovery();
        }
      }
    }

    private void openSocket(BluetoothAdapter adapter) throws IOException {
      // 2. ????????????MacAddress,?????????????????????????????????
      BluetoothDevice device = adapter.getRemoteDevice(currentMacAddress);
      int sdk = Build.VERSION.SDK_INT;
      UUID MY_UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB");

      if (sdk >= 10) {
        mySocket = device.createInsecureRfcommSocketToServiceRecord(MY_UUID);
      } else {
        mySocket = device.createRfcommSocketToServiceRecord(MY_UUID);
      }
    }
  }

  // 5.???????????????
  private class ReceiveDatas extends Thread {
    @Override
    public void run() {
      InputStream mmInStream = null;
      BufferedReader reader = null;

      try {
        mmInStream = mySocket.getInputStream();
        handler.sendEmptyMessage(2);
        // ???????????????
        while (mySocket.isConnected()&&!flag) {
          try {
            reader = new BufferedReader(new InputStreamReader(mmInStream, "UTF-8")); // ??????????????????????????????????????????
            String line; // ????????????????????????????????????
            while ((line = reader.readLine()) != null) {

              try {
                //btNmeaUtils.handleNmea(line);
                //Log.i(TAG,line);
                Message message = new Message();
                message.what = 0;
                Bundle bundle = new Bundle();
                bundle.putString("line",line);
                message.setData(bundle);
                handler.sendMessage(message);


              } catch (Exception ex) {
//                                logger.content = "Exception==>" + (TextUtils.isEmpty(ex.getMessage()) ? "" : ex.getMessage());
//                                DatabaseHelper.getInstance().insert(logger);
                ex.printStackTrace();
              }
            }
          } catch (Exception ex) {
            ex.printStackTrace();
            if (reader != null){
              reader.close();
            }
          }
        }
      } catch (Exception ex) {
        ex.printStackTrace();
      } finally {
        try {
          if (mmInStream != null) {
            mmInStream.close();
          }
        } catch (Exception ex) {
          ex.printStackTrace();
        }
      }
    }
  }
  private static class MyHandler extends Handler{
    private final WeakReference<RtkBluetoothPlugin> mTarget;
    public MyHandler(RtkBluetoothPlugin plugin){
      mTarget = new WeakReference<RtkBluetoothPlugin>(plugin);

    }

    @Override
    public void handleMessage(@NonNull Message msg) {
      super.handleMessage(msg);
      RtkBluetoothPlugin plugin = mTarget.get();
      if (msg.what == 0){
        String line = msg.getData().getString("line");
        plugin.channel.invokeMethod("onNmeaChange",line);
      }else if(msg.what == 2){
        String  json = JsonUtil.toJson(MapUtil.deepToMap(plugin.getResultBean(true,"??????????????????")));
        plugin.currentResult.success(json);
      }
    }
  }


  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
