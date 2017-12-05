using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class test : MonoBehaviour
{

    public Text text1;
    public Text text2;
    public Text text3;
    public Text text4;
    public Text text5;
    public Button btn;  
    // Use this for initialization
    void Start ()
    {
//        text1.text = "1 " + UnityEngine.iOS.Device.advertisingIdentifier;
//        text2.text = "2 " + UnityEngine.iOS.Device.advertisingTrackingEnabled.ToString ();
//        text3.text = "3 " + UnityEngine.iOS.Device.generation.ToString ();
//        text4.text = "4 " + UnityEngine.iOS.Device.systemVersion;
//        text5.text = "5 " + UnityEngine.iOS.Device.vendorIdentifier;
//        Debug.Log ("AdvertisingIdentifier " + iOSDeviceInfo.AdvertisingIdentifier ());
//        Debug.Log ("AdvertisingTrackingEnabled " + iOSDeviceInfo.AdvertisingTrackingEnabled ());
//        Debug.Log ("VendorIdentifier " + iOSDeviceInfo.VendorIdentifier ());
//        Debug.Log ("DeviceName " + iOSDeviceInfo.DeviceName ());
//        Debug.Log ("SystemName " + iOSDeviceInfo.SystemName ());
//        Debug.Log ("SystemVersion " + iOSDeviceInfo.SystemVersion ());
//        Debug.Log ("DeviceModel " + iOSDeviceInfo.DeviceModel ());
//        Debug.Log ("DeviceCPUCount " + iOSDeviceInfo.DeviceCPUCount ());
//        Debug.Log ("SystemLanguage " + iOSDeviceInfo.SystemLanguage ());
//        Debug.Log ("DeviceGeneration " + iOSDeviceInfo.DeviceGeneration ());
//        Debug.Log ("DeviceIsStylusTouchSupported " + iOSDeviceInfo.DeviceIsStylusTouchSupported ());
//        Debug.Log ("DeviceIsWideColorSupported " + iOSDeviceInfo.DeviceIsWideColorSupported ());
//        Debug.Log ("DeviceDPI " + iOSDeviceInfo.DeviceDPI ());

        btn.GetComponent<Button>().onClick.AddListener(delegate() {  
            iOSWeChatBridge.WeiXinLogin();
        }); 
    }
	
    // Update is called once per frame
    void Update ()
    {
		
    }
}











