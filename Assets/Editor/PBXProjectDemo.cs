using System.IO;
using UnityEngine;

#if UNITY_EDITOR
using UnityEditor;
using UnityEditor.iOS.Xcode;
using UnityEditor.Callbacks;
using UnityEditor.XCodeEditor;
#endif
using System.Collections;

public class PBXProjectDemo
{
    //该属性是在build完成后，被调用的callback
    [PostProcessBuildAttribute (0)]
    public static void OnPostprocessBuild (BuildTarget buildTarget, string pathToBuiltProject)
    {
        // BuildTarget需为iOS
        if (buildTarget != BuildTarget.iOS)
            return;

        // 初始化
        var projectPath = pathToBuiltProject + "/Unity-iPhone.xcodeproj/project.pbxproj";
        PBXProject pbxProject = new PBXProject ();
        pbxProject.ReadFromFile (projectPath);
        string targetGuid = pbxProject.TargetGuidByName ("Unity-iPhone");

        // 添加flag
        pbxProject.AddBuildProperty (targetGuid, "OTHER_LDFLAGS", "-ObjC");
        // 关闭Bitcode
        pbxProject.SetBuildProperty (targetGuid, "ENABLE_BITCODE", "NO");

        // 添加framwrok
        pbxProject.AddFrameworkToProject (targetGuid, "Security.framework", false);
        pbxProject.AddFrameworkToProject (targetGuid, "CoreTelephony.framework", false);
        pbxProject.AddFrameworkToProject (targetGuid, "SystemConfiguration.framework", false);
        pbxProject.AddFrameworkToProject (targetGuid, "CoreGraphics.framework", false);
        pbxProject.AddFrameworkToProject (targetGuid, "ImageIO.framework", false);
        pbxProject.AddFrameworkToProject (targetGuid, "CoreData.framework", false);
        pbxProject.AddFrameworkToProject (targetGuid, "CFNetwork.framework", false);

        //添加lib
        AddLibToProject (pbxProject, targetGuid, "libsqlite3.tbd");
        AddLibToProject (pbxProject, targetGuid, "libc++.tbd");
        AddLibToProject (pbxProject, targetGuid, "libz.tbd");

        // 应用修改
        File.WriteAllText (projectPath, pbxProject.WriteToString ());



        // 修改Info.plist文件
        var plistPath = Path.Combine(pathToBuiltProject, "Info.plist");
        var plist = new PlistDocument();
        plist.ReadFromFile(plistPath);
        // 插入URL Scheme
        var array = plist.root.CreateArray("CFBundleURLTypes");
        var urlDict = array.AddDict();
        urlDict.SetString("CFBundleTypeRole", "Editor");
        urlDict.SetString("CFBundleURLName", "weixin");
        var urlInnerArray = urlDict.CreateArray("CFBundleURLSchemes");
        urlInnerArray.AddString("wxc99bd144ac341969");
        // 插入白名单
        var LSApplication = plist.root.CreateArray("LSApplicationQueriesSchemes");
        LSApplication.AddString("weixin");
        LSApplication.AddString("wechat");
        // 插入权限
        plist.root.SetString("NSMicrophoneUsageDescription", "申请麦克风权限");
        // 应用修改
        plist.WriteToFile(plistPath);



        //插入代码
        //读取UnityAppController.mm文件
        string unityAppControllerPath = pathToBuiltProject + "/Classes/UnityAppController.mm";
        XClass UnityAppController = new XClass (unityAppControllerPath);

        //在指定代码后面增加一行代码
        UnityAppController.WriteBelow ("#include \"PluginBase/AppDelegateListener.h\"", "#import \"WXApiManager.h\"//liuwei");

  
        //在指定代码后面增加一行代码
        UnityAppController.WriteBelow ("AppController_SendNotificationWithArg(kUnityOnOpenURL, notifData);", "    return [WXApi handleOpenURL:url delegate:[WXApiManager sharedManager]];//liuwei");


        //在指定代码后面增加一行代码
        UnityAppController.WriteBelow ("[KeyboardDelegate Initialize];", "    [WXApi registerApp:WXAPPID];//liuwei");


        //在指定代码后面增加一行代码
        string strCode = "- (BOOL)application:(UIApplication*)application willFinishLaunchingWithOptions:(NSDictionary*)launchOptions\n"
                         + "{\n"
                         + "    return YES;\n"
                         + "}\n";
        string newCode = "\n"
                         + "- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {\n"
                         + "    return  [WXApi handleOpenURL:url delegate:[WXApiManager sharedManager]];//liuwei\n"
                         + "}\n"
                         + "\n";
        UnityAppController.WriteBelow (strCode, newCode);

    }

    //添加lib方法
    static void AddLibToProject (PBXProject inst, string targetGuid, string lib)
    {
        string fileGuid = inst.AddFile ("usr/lib/" + lib, "Frameworks/" + lib, PBXSourceTree.Sdk);
        inst.AddFileToBuild (targetGuid, fileGuid);
    }
}
