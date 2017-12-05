using UnityEngine;
using System.Collections;
using System.Runtime.InteropServices;

public class iOSWeChatBridge
{
    [DllImport ("__Internal")]
    private static extern void _weixinlogin ();


    public static void WeiXinLogin ()
    {
        _weixinlogin ();
    }


}
