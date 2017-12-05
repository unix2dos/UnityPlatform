using UnityEngine;
using System.Collections;
using System.Runtime.InteropServices;

public class iOSDeviceInfoBridge
{
    [DllImport ("__Internal")]
    private static extern string _AdvertisingIdentifier ();
    [DllImport ("__Internal")]
    private static extern string _VendorIdentifier ();
    [DllImport ("__Internal")]
    private static extern string _DeviceName ();
    [DllImport ("__Internal")]
    private static extern string _SystemName ();
    [DllImport ("__Internal")]
    private static extern string _SystemVersion ();
    [DllImport ("__Internal")]
    private static extern string _DeviceModel ();
    [DllImport ("__Internal")]
    private static extern string _SystemLanguage ();
    [DllImport ("__Internal")]
    private static extern string _CarrierName ();
    [DllImport ("__Internal")]
    private static extern string _DeviceToken ();
    [DllImport ("__Internal")]
    private static extern string _NetType ();


    public static string AdvertisingIdentifier ()
    {
        return _AdvertisingIdentifier ();
    }

    public static string VendorIdentifier ()
    {
        return _VendorIdentifier ();
    }

    public static string DeviceName ()
    {
        return _DeviceName ();
    }

    public static string SystemName ()
    {
        return _SystemName ();
    }

    public static string SystemVersion ()
    {
        return _SystemVersion ();
    }

    public static string DeviceModel ()
    {
        return _DeviceModel ();
    }


    public static string SystemLanguage ()
    {
        return  _SystemLanguage ();
    }


    public static string CarrierName ()
    {
        return _CarrierName ();
    }

    public static string DeviceToken ()
    {
        return _DeviceToken ();
    }

    public static string NetType ()
    {
        return _NetType ();
    }
}
