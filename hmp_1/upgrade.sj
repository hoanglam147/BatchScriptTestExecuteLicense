//USEUNIT lib_deviceInfo
//USEUNIT lib_validate
//USEUNIT lib_err
//USEUNIT lib_common
//USEUNIT lib_SaveJob
//USEUNIT lib_OpenJob
//USEUNIT lib_DeviceSelectedDetail
//USEUNIT lib_updateConfig
//USEUNIT installation
//USEUNIT lib_UserRole
//USEUNIT changeUISettingsWindow 
//USEUNIT lib_CodeSetup 
//USEUNIT lib_common 

function mainDownadnUp()
{
  lib_common.launchUI()
  temp = Sys.Process("DL.CODE").FindChild("WPFControlName", "OnlineDevicesAccordionItem", 1000);
  deviceTreeView = temp.FindChild("ClrClassName", "DeviceTreeView", 1000);
  var ip = [];
  var serialNumber = [];
  for(i = 1;i<deviceTreeView.ChildCount;i++)
  {
    obj = deviceTreeView.WPFObject("TreeViewItem", "", i);    
    var seriali = obj.WPFObject("mastergrid").WPFObject("StackPanel", "", 1).WPFObject("Grid", "", 2).WPFObject("StackPanel", "", 2).WPFObject("TextBlock", "*", 3).WPFControlText;
    var ipi = obj.WPFObject("mastergrid").WPFObject("StackPanel", "", 1).WPFObject("Grid", "", 2).WPFObject("StackPanel", "", 1).WPFObject("TextBlock", "*", 2).WPFControlText;
    ipi = aqString.SubString(ipi, 1 , ipi.length - 1);
    ip.push(ipi);
    serialNumber.push(seriali);
  }
  //var ip = ["10.84.30.63", "10.84.30.64", "10.84.30.127"];
  //var serialNumber = ["C18L02684", "C14P00017", "C14P00582"];
  for(i=0;i<ip.length;i++)
  {
      var deviceModel = downGrade(ip[i], serialNumber[i]);
      //if(deviceModel == null) continue;
      //upgrade2(ip[i], deviceModel, serialNumber[i]);
  }

}


function installBothGUI_LastOfficial_And_Latest()
{
  if(LatestBuildSW_Version == "")
  {
    installation.ReadDataFromExcel();
  }
  
  //if (isExistPrg(aqString.SubString(LatestGUI, 0, 13)) != "")
  {
    
  }
  //else
  {
    //var latestBuild = initLatestBuildInformation();
    //installation.Install(latestBuild, false);
  }
  //if(isExistPrg(aqString.SubString(LastOfficicalGUI, 0, 13)) != "")
  {
    
  }
  //else
  {
    var lastOfficialBuild = initLastOfficialBuildInformation();
    installation.Install(lastOfficialBuild, false);
  }
    var latestBuild = initLatestBuildInformation();
    installation.Install(latestBuild, true);
    var lastOfficialBuild = initLastOfficialBuildInformation();
    installation.Install(lastOfficialBuild, true);    
    
}
//author: lhoang
function connectToDevice2(ip)
{
  lib_common.clickOnMenu("Device", "Connect to Device");
  
  while(true)
  { 
    connectPopup = Sys.Process("DL.CODE").FindChild("ClrFullClassName", "IVS_UI.Views.Popups.ConnectToWindow", 1000);
    if(connectPopup.Exists)
    {
      if(connectPopup.Visible)
      {
        ipBox = connectPopup.FindChild("ClrFullClassName", "IVSControls.Controls.IpAddressControl", 1000);
        ipBox.set_IpAddress(ip);
        delay(3000);
        arrPro = ["ClrClassName", "WPFControlText"];
        arrVal = ["Button", "Connect"];
        connectBtn = connectPopup.FindChild(arrPro, arrVal, 1000);
        connectBtn.Click();
        break;
      }
    }
    delay(1000);
  }
  delay(3000);
  connectPopup = Sys.Process("DL.CODE").FindChild("ClrFullClassName", "IVS_UI.Views.Popups.ConnectToWindow", 1000);
  while(connectPopup.Exists)
  {
    Sys.Refresh();
  }
  while(true)
  {
    if(Sys.Process("DL.CODE").WaitWPFObject("HwndSource: Window", 1000).Exists)
    {
      p = Sys.Process("DL.CODE").WPFObject("HwndSource: Window");
      message = p.FindChild("WPFControlName", "MessageText", 1000).WPFControlText
      if(aqString.Contains(message, "Attention") != -1)
      {
        p.FindChild("WPFControlName", "btnOK", 1000).Click();
        flag = false;
       
      }
      else
      {
        flag = true;
      }
      break;
    }
    if(Sys.Process("DL.CODE").FindChild("WPFControlText", "Open Device Configuration", 1000).Exists)
    {
      flag = true;
      break;
    }
  }
  return flag;
}
function downGrade(ip, serialNumber)
{
  //Log.Message("First step: Install last official GUI and latest GUI if NOT");
  //installBothGUI_LastOfficial_And_Latest(); 
  installation.ReadDataFromExcel(); 
  Log.Message("Terminate all exists DL.CODE UI");
  lib_common.terminateUI();
  Log.Message("Run latest GUI, get device info, change job to Default job");
  lib_common.runTestedApp();
    //change to user expert
  if(!Sys.Process("DL.CODE").FindChild("WPFControlText", "Installer-Expert", 1000).Exists)
  {
    arrPro = ["ClrClassName", "ToolTip"];
    arrVal = ["Button", "Change User"];
    changeUserObj = Sys.Process("DL.CODE").FindChild(arrPro, arrVal, 1000);
    changeUserObj.Click();
    changeUserObj.PopupMenu.Click("Installer-Expert");
  }
  if(!connectToDevice2(ip)) return null;
  
  var arrayDeviceInfo = lib_common.getDeviceInformation();
  Sys.Process("DL.CODE").WPFObject("HwndSource: DeviceEnvironmentConfigurationPopup", "Device Environment Configuration").Close();
  var includeLoaderDownGrade = !(arrayDeviceInfo[8] == LastOfficialLoader);
  var model = arrayDeviceInfo[1];
  if(aqString.Contains(model, "M120", 0) != -1)
  {
    model = "M120";
  }
  else if(aqString.Contains(model, "M220", 0)!= -1)
  {
    model = "M220";
  }
  else if(aqString.Contains(model, "M300", 0)!= -1)
  {
    model = "M300N";
  }
  else if(aqString.Contains(model, "M410", 0)!= -1)
  {
    model = "M410N";
  }
  else if(aqString.Contains(model, "M450", 0)!= -1)
  {
    model = "M450N";
  }
  else
  {
    
  }
  lib_OpenJob.openOnDevice( lib_const.const_DefaultJob,lib_const.const_isDefaultJob_Y,lib_const.const_isOpenViaButton_N);
  Log.Message("Then terminate UI");
  lib_common.terminateUI();
  Log.Message("Run last official GUI, connect to device, downgrade device");
  lib_common.runDLCODELastOfficial();
      //change to user expert
  if(!Sys.Process("DL.CODE").FindChild("WPFControlText", "Installer-Expert", 1000).Exists)
  {
    arrPro = ["ClrClassName", "ToolTip"];
    arrVal = ["Button", "Change User"];
    changeUserObj = Sys.Process("DL.CODE").FindChild(arrPro, arrVal, 1000);
    changeUserObj.Click();
    changeUserObj.PopupMenu.Click("Installer-Expert");
  }
  
  connectToDevice2(ip);
  if(!ProcessDownGrade(includeLoaderDownGrade, model, serialNumber)) return null;

  var includeLoaderUpGrade = !(arrayDeviceInfo[8] == LatestLoader);
  if(!includeLoaderDownGrade && !includeLoaderUpGrade) 
  {
    includeLoaderUpGrade = false;
  }
  else
  {
    includeLoaderUpGrade = true;
  }
  
  if(!verifyPackageAndLoader(ip, "DL.CODE " + LastOfficicalGUI, SWLastOfficialBuild_SW_Version, LastOfficialLoader)) return null;
  var indexConfig = Math.round(Math.random()*(9-1)+1)
  if(!createConfigForUpgrade(indexConfig)) return null;
  lib_deviceInfo.const_firmware = temp;
  return model;
}
function ProcessDownGrade(model, serialNumber)
{
  while(!Sys.Process("DL.CODE").WaitWPFObject("HwndSource: Window", 1000).Exists)
  {
    if(Sys.Process("DL.CODE").WPFObject("HwndSource: Shell", "DL.CODE*").Enabled)
    {
      break;
    }
  }
  if(Sys.Process("DL.CODE").WaitWPFObject("HwndSource: Window", 1000).Exists)
  {
    Sys.Process("DL.CODE").WPFObject("HwndSource: Window").WPFObject("Window").WPFObject("Grid", "", 1).WPFObject("Grid", "", 2).WPFObject("ButtonPanel").WPFObject("btnYes").ClickButton();
  }
  else
  {
    lib_common.clickOnMenu("Device", "Update Package");
  }
  GUIRevision = "DL.CODE " + aqString.SubString(LastOfficicalGUI, 0, 5);
  if(!SelectPackage(GUIRevision, model, SWLastOfficialBuild_SW_Version)) return false;
  WaitingDone(serialNumber, GUIRevision);
  return true;
}

function verifyPackageAndLoader(ip, GUIVersion, packageFW, loader)
{
  if(!connectToDevice2(ip)) return false;
  checkStop = false;
  while(!checkStop)
  {
    currentFWLabel = Sys.Process("DL.CODE").FindChild("WPFControlText", "Application SW Version", 1000);
    if(currentFWLabel.Exists)
    {
      checkStop = true;
    }
    delay(3000)
  }
  
  currentFWLabel = Sys.Process("DL.CODE").FindChild("WPFControlText", "Application SW Version", 1000);
  currentFW = currentFWLabel.Parent.WPFObject("TextBlock", "*", 2).WPFControlText;
  currentLoaderLabel = Sys.Process("DL.CODE").FindChild("WPFControlText", "Loader Version", 1000);
  currentLoader = currentLoaderLabel.Parent.WPFObject("TextBlock", "*", 2).WPFControlText;
  if((packageFW == currentFW) && (currentLoader == loader))
  {
    Log.Checkpoint("up/downgrade OK, new package and loader applied: " + currentFW + ", "  + currentLoader);
    return true;
  }
  else
  {
    Log.Error("up/downgrade FAIL");
    Log.Message("expected: " + packageFW + ", " + loader);
    Log.Message("actal: " + currentFW + ", " + currentLoader);
    return false;
  }  
}
function createConfigForUpgrade(configNumber)
{
  temp = lib_deviceInfo.const_firmware;
  lib_deviceInfo.const_firmware= "DL.CODE " + LastOfficicalGUI;
  switch(configNumber)
  {
    case 1:// ram 
      flag= createConfigForUpgrade1();
      break;
    case 2: // ftp
      flag= createConfigForUpgrade2();
      break;
    case 3: //cr
      flag= createConfigForUpgrade3();
      break;
    case 4: // 2image
      flag=createConfigForUpgrade4();
      break;
    case 5:// phase
      flag=createConfigForUpgrade5();
      break;
    case 6: // presentation mode
      flag=createConfigForUpgrade6();
      break;
    case 7: // cr + filter
      flag=createConfigForUpgrade7();
      break;
    case 8: // fieldbus
      flag=createConfigForUpgrade8();
      break;
    case 9: //
      flag=createConfigForUpgrade9();
      break;
    default:
    break;
  }
  lib_deviceInfo.const_firmware = temp;
  return flag;
}
function createConfigForUpgrade1()
{
  flag = true;
  openJobOnDevice2("Default");
  delay(1000);
  lib_button.clickDataFortmating2();
  delay(1000);
  lib_DataFormating.addImageSaving2();
  delay(1000);
  if(!lib_SaveJob.saveJobOnDevice2(LastOfficicalGUI + "_RAM")) flag= false;
  lib_common.terminateUI();  
  return flag;
}

function createConfigForUpgrade2()
{
  flag = true;
  openJobOnDevice2("Default");
  delay(1000);
  lib_button.clickReadingPhase2();
  delay(1000);
  // change to periodic
  Sys.Process("DL.CODE").FindChild("WPFControlText", "Periodic (ms)", 1000).Parent.Click();
  delay(1000);
  lib_button.clickDataFortmating2();
  delay(1000);
  lib_DataFormating.addFTP();
  delay(1000);
  lib_DataFormating.addImageSaving2();
  lib_DataFormating.changeImageSavingRemote("FTP");
  if(!lib_SaveJob.saveJobOnDevice2(LastOfficicalGUI + "_FTP")) flag= false;
  lib_common.terminateUI();
  return flag; 
}
function createConfigForUpgrade3()
{
  flag = true;
  openJobOnDevice2("Default");
  delay(1000);
  lib_button.clickAdvancedSetup();
  // add CR
  Sys.Process("DL.CODE").FindChild("CurrentToolTip", "JobConfiguration.ControlToolBar.CropImage", 1000).Click(); 
  delay(2000);
  lib_CodeSetup.editCroppingRegion(0,0,562,544);
  if(!lib_SaveJob.saveJobOnDevice2(LastOfficicalGUI + "_CR")) flag = false;
  lib_common.terminateUI();   
  return flag;
}
function createConfigForUpgrade4()
{
  flag = true;
  openJobOnDevice2("Default");
  delay(1000);
  lib_button.clickAdvancedSetup();
  // add new image
  Sys.Process("DL.CODE").FindChild("ToolTip", "Add New Image Setup", 1000).Click();
  if(!lib_SaveJob.saveJobOnDevice2(LastOfficicalGUI + "_2Image")) flag = false;
  lib_common.terminateUI();
  return flag;   
}
function createConfigForUpgrade5()
{
  flag = true;
  openJobOnDevice2("Default");
  delay(1000);  
  lib_button.clickReadingPhase2();
  // add phase
  Sys.Process("DL.CODE").FindChild("ToolTip", "Phase Mode", 1000).Click();
  if(!lib_SaveJob.saveJobOnDevice2(LastOfficicalGUI + "_Phase")) flag = false;
  lib_common.terminateUI();  
  return flag;
}
function createConfigForUpgrade6()
{
  flag = true;
  //enter presentation mode;
  Sys.Process("DL.CODE").FindChild("WPFControlText", "Presentation Mode", 1000).Click();
  delay(5000);
  lib_button.clickAdvancedSetup();
  if(!lib_SaveJob.saveJobOnDevice2(LastOfficicalGUI + "_PresentationMode")) flag =false;
  lib_common.terminateUI();  
  return flag;  
}
function createConfigForUpgrade7()
{
  flag = true;
  openJobOnDevice2("Default");
  delay(1000);
  lib_button.clickAdvancedSetup();
  // add CR
  Sys.Process("DL.CODE").FindChild("CurrentToolTip", "JobConfiguration.ControlToolBar.CropImage", 1000).Click();
  delay(2000);
  lib_CodeSetup.editCroppingRegion(0,0,562,544);
  // add Filter
  Sys.Process("DL.CODE").FindChild("ToolTip", "Add New Filter", 1000).Click();
  if(!lib_SaveJob.saveJobOnDevice2(LastOfficicalGUI + "_PresentationMode")) flag = false;
  lib_common.terminateUI(); 
  return flag; 
}
function createConfigForUpgrade8()
{
  flag = true;
  openJobOnDevice2("Default");
  delay(1000);  
  lib_button.clickReadingPhase2();
  addFieldbusObj = Sys.Process("DL.CODE").FindChild("ToolTip", "Add New Fieldbus", 1000);
  arrFieldbusList = ["Ethernet/IP", "Modbus Client", "Modbus Server", "SLMP", "Profinet IO", "HMS Fieldbus"];
  index = Math.round(Math.random()*(arrFieldbusList.length-1));
  addFieldbusObj.PopupMenu.Click(arrFieldbusList[index]);
  if(!lib_SaveJob.saveJobOnDevice2(LastOfficicalGUI + arrFieldbusList[index])) flag = false;
  lib_common.terminateUI();
  return flag;
}
function createConfigForUpgrade9()
{
  flag = true;
  openJobOnDevice2("Default");
  delay(1000);
  lib_button.clickAdvancedSetup();
  // add CR
  Sys.Process("DL.CODE").FindChild("ToolTip", "Add Cropping Region", 1000).Click();
  delay(2000);
  lib_CodeSetup.editCroppingRegion(0,0,562,544);
  //add filter
  Sys.Process("DL.CODE").FindChild("ToolTip", "Add New Filter", 1000).Click();
  // add new image
  Sys.Process("DL.CODE").FindChild("ToolTip", "Phase Mode", 1000).Click();
  delay(1000);  
  lib_button.clickReadingPhase2();
  // add phase
  Sys.Process("DL.CODE").FindChild("ToolTip", "Phase Mode", 1000).Click();
  //add fieldbus
  addFieldbusObj = Sys.Process("DL.CODE").FindChild("ToolTip", "Add New Fieldbus", 1000);
  arrFieldbusList = ["Ethernet/IP", "Modbus Client", "Modbus Server", "SLMP", "Profinet IO", "HMS Fieldbus"];
  index = Math.round(Math.random()*(arrFieldbusList.length-1)+1);
  addFieldbusObj.PopupMenu.Click(arrFieldbusList[index]);
  delay(2000); 
  lib_button.clickDataFortmating2();
  delay(1000);
  lib_DataFormating.addImageSaving2();
    
  if(!lib_SaveJob.saveJobOnDevice2(LastOfficicalGUI + "_ComplicatedConfiguration")) flag =false;
  lib_common.terminateUI();
  return flag;
}
function SelectPackage(version, deviceModel, firmware)
{
  version = aqString.SubString(version , 0, 13);
  var pathPackageFolder = ProgramData + "\\" + version + "\\DevicePackages\\";
  var pathPackageFile = "";
  var foundFiles, aPath;
  deviceModel = "*" + deviceModel + "*";
  foundFiles = aqFileSystem.FindFiles(pathPackageFolder, deviceModel);
  if(foundFiles !=null)
  {
    while(foundFiles.HasNext())
    {
      aPath = foundFiles.Next();
      pathPackageFile = aPath.Path;
      Log.Message(pathPackageFile);
    }
  }
  if(pathPackageFile == "") 
  {
    Log.Error("Can not found package for up/downgrade");
    return;
  }
  Sys.Process("DL.CODE").Window("#32770", "Open", 1).Window("ComboBoxEx32", "", 1).Window("ComboBox", "", 1).Window("Edit", "", 1).SetText(pathPackageFile);
  Sys.Process("DL.CODE").Window("#32770", "Open", 1).Window("Button", "&Open", 1).ClickButton();
  while(!Sys.Process("DL.CODE").WaitWPFObject("HwndSource: Window", 1000).Exists)
  {
    
  }
  var str = Sys.Process("DL.CODE").WPFObject("HwndSource: Window").WPFObject("Window").WPFObject("Grid", "", 1).WPFObject("Grid", "", 1).WPFObject("MessageText").WPFControlText;
  if(aqString.Contains(str, firmware, 0) != -1)
  {
    Log.Checkpoint("Package selected for downgrade is correct");
    Sys.Process("DL.CODE").WPFObject("HwndSource: Window").WPFObject("Window").WPFObject("Grid", "", 1).WPFObject("Grid", "", 2).WPFObject("ButtonPanel").WPFObject("btnYes").ClickButton();
    return true;
  }
  else if(aqString.Contains(str, "not allowed", 0) != -1)
  {
    Log.Error("Package selected for downgrade isn't correct");
    Sys.Process("DL.CODE").WPFObject("HwndSource: Window").WPFObject("Window").WPFObject("Grid", "", 1).WPFObject("Grid", "", 2).WPFObject("ButtonPanel").WPFObject("btnOK").Click();
    return false;
  }
  else
  {
    Log.Error("Package selected for downgrade isn't correct");
    Sys.Process("DL.CODE").WPFObject("HwndSource: Window").WPFObject("Window").WPFObject("Grid", "", 1).WPFObject("Grid", "", 2).WPFObject("ButtonPanel").WPFObject("btnNo").Click();
    return false;
  }
  
}
function SelectLoader(version)
{
  
}

function WaitingDone(serial, GUIVersion)
{
  while(!Sys.Process("DL.CODE").WaitWPFObject("HwndSource: Window", 1000).Exists)
  {
    
  }
  str = Sys.Process("DL.CODE").WPFObject("HwndSource: Window").WPFObject("Window").WPFObject("Grid", "", 1).WPFObject("Grid", "", 1).WPFObject("MessageText").WPFControlText;
  strBase = "Attention: device is being restarted and changes will be applied at next boot!";
  if(aqString.Compare(strBase, str, true) != 0)  
  { 
    Log.Message(str);
    Log.Message(strBase);
    Log.Message(str.length);
    Log.Message(strBase.length);
    Log.Warning("Attention error while downgrade");
    lib_common.restartDevice(lib_deviceInfo.const_Device_IP_Adress);
  }
  Sys.Process("DL.CODE").WPFObject("HwndSource: Window").WPFObject("Window").WPFObject("Grid", "", 1).WPFObject("Grid", "", 2).WPFObject("ButtonPanel").WPFObject("btnOK").ClickButton();
  delay(5000);
  var checkStop = false;
  while(!checkStop)
  {
    leftPanel = Sys.Process("DL.CODE").FindChild("WPFControlName", "uxAccordion", 1000);
    //fatherPathAllDeviceOnline = leftPanel.FindChild("ClrClassName", "DeviceTreeView", 1000);
    //var childCountOnlineDevice = fatherPathAllDeviceOnline.ChildCount;
    if(leftPanel.FindChild("WPFControlText", serial, 1000).Exists)
    {
      checkStop = true;
    }
    delay(3000);
    Sys.Refresh();
  }
  
  delay(7000);
}
function mainDownAndUpgrade ()
{ 
        //verify the last and current build are installed
        if (installation.isExistPrg(lib_updateConfig.guiLstVersion) == "")
              installation.instDL_1_7_0( );  
                   
        if (installation.isExistPrg(lib_updateConfig.guiCurrVersion) == "")
        {      
                  var currVersion = new Object();
                  currVersion = installation.initCurrVersion();
                  installation.installation(currVersion, false);
        
        }  
        // check then config GUI and user role        
        lib_UserRole.initUISetting_UserRole ();
        changeUISettingsWindow.changeUISettingsWindow();
                
        //preform downgrade
        var firmware = getDvPkg (lib_deviceInfo.const_Device_Model,lib_updateConfig.lastListPgks);
        var downFlag = updateFIRMWARE (lib_deviceInfo.const_Device_IP_Adress, lib_updateConfig.const_lastPATH_Firmware, firmware)   ;
        if (downFlag == lib_err.err_FUNC_SUCCESS) 
        {
              //perform upgrade
              upgrade();
        }else
          Log.Warning("pls check manually.DOWNGRADE failed.");
}

/*
  *@function perform upgrading
*/ 
function upgrade ()
{ 
        lib_common.launchUI();
        //device at last official release
        var device_Before = new Object();  
        //Expected device after upgrade new release
        var device_Expected = new Object(); 
        //REAL device after upgrade release
        var device_After = new Object(); 
        //get device information           
        device_Before = lib_DeviceSelectedDetail.getDeviceCurrent(lib_deviceInfo.const_Device_IP_Adress);  
        //init value to expected device
        device_Expected = device_Before;
        device_Expected.loaderVersion = const_currLoaderNo;
        device_Expected.vlLibrary = const_currVLlibrary;
        device_Expected.frmware = const_firmware_version;      
 
        var upgrade = updateFIRMWARE (lib_deviceInfo.const_Device_IP_Adress, lib_updateConfig.const_currPATH_Firmware, getDvPkg (lib_deviceInfo.const_Device_Model,lib_updateConfig.currListPgks)   )  ;
        if (upgrade == lib_err.err_FUNC_SUCCESS)
        {        
              device_After   = lib_DeviceSelectedDetail.getDeviceCurrent(lib_deviceInfo.const_Device_IP_Adress);
               
              //verify After & Expected
              var compare = lib_DeviceSelectedDetail.compareDevice(device_After, device_Expected);
              //verify selected & Environment   
              Log.Message("compareDevice: " + compare);
              
              if (device_After.loaderVersion != const_currLoaderNo)
                   Log.Error(device_After.loaderVersion);
              if (device_After.vlLibrary != const_currVLlibrary)
                   Log.Error(device_After.vlLibrary);
              if (device_After.frmware != const_firmware_version)     
                   Log.Error(device_After.frmware);
                   
              Log.Message("device Expected:")   
              dislayDeviceInfo (device_Expected);  
              Log.Message("device after:")   
              dislayDeviceInfo (device_After);    
        }else         
        {
                   Log.Warning("Pls check manually. Because the UPGRADE process: " + false);
                   Log.Warning("Perform Restart then re-verify firmware ");
                   
                   lib_common.restartDevice(lib_deviceInfo.const_Device_IP_Adress); 
                   Delay( 10000);
                   device_After   = lib_DeviceSelectedDetail.getDeviceCurrent(lib_deviceInfo.const_Device_IP_Adress);
               
                  //verify After & Expected
                  var compare = lib_DeviceSelectedDetail.compareDevice(device_After, device_Expected);
                  //verify selected & Environment   
                  Log.Message("compareDevice: " + compare);
              
                  if (device_After.loaderVersion != const_currLoaderNo)
                       Log.Error(device_After.loaderVersion);
                  if (device_After.vlLibrary != const_currVLlibrary)
                       Log.Error(device_After.vlLibrary);
                  if (device_After.frmware != const_firmware_version)     
                       Log.Error(device_After.frmware);
                   
                  Log.Message("device Expected:")   
                  dislayDeviceInfo (device_Expected);  
                  Log.Message("device after:")   
                  dislayDeviceInfo (device_After);   
        }
}


/*
    @function:return device package
    @modelDevice {String} exp: M300N/ M210N,...
    @lstPkg {Array} array of packages 
    @return {String}device package
*/
function getDvPkg (modelDevice ,lstPkg )
{
     var str = "";
     for (var i = 0; i<  lstPkg.length ;i ++)
     {    
          if (aqString.Contains(lstPkg[i], modelDevice , 0, true) != -1)
              return lstPkg[i];
     }
     return str; 
}

/**
 * @function: include upgrading and downgrading
 * @ipDevice {String} ip of device
 * @param {String} path to FW
 * @param {String} package of FW
*/ 
function updateFIRMWARE (  ipDevice, path , firmware)
{
      //Log.AppendFolder("func: updateFIRMWARE");
      lib_common.launchUI();      
      var flag = lib_err.err_FUNC_FAILED;       
      try
      {
             if ( connectToDevice(ipDevice) == lib_err.err_FUNC_SUCCESS)
             {
                  var IvsMenu =Sys.Process("DL.CODE").WPFObject("HwndSource: Shell", lib_deviceInfo.const_firmware).WPFObject("Shell", lib_deviceInfo.const_firmware, 1).WPFObject("Border", "", 1).WPFObject("DockPanel", "", 1).WPFObject("Grid", "", 1).WPFObject("Border", "", 2).WPFObject("Grid", "", 1).WPFObject("IvsMenu"); 
                  IvsMenu.WPFObject("MenuItem",lib_label.const_lb_Device, 3).Click();
                  IvsMenu.WPFMenu.Click(lib_label.const_lb_Device +"|" + lib_label.const_lb_UpdatePackage);
                  
                   while (!Sys.Process("DL.CODE").WaitWindow("#32770", "*",1, lib_const.const_delay_1000).Exists){
                          Delay(lib_const.const_delay_1000);
                          Sys.Process("DL.CODE").Refresh();
                    }     
                    //open folder contain job
                    var editBar =Sys.Process("DL.CODE")["Window"]("#32770", "*", 1)["Window"]("ComboBoxEx32", "", 1)["Window"]("ComboBox", "", 1)["Window"]("Edit", "", 1);
                    editBar.Keys(path  + "\\"+ firmware);
                    editBar.Keys("[Enter]");  
                  
                    if (Sys.Process("DL.CODE").WaitWPFObject("HwndSource: Window", lib_const.const_delay_1000).Exists)
                    {                          
                          aqObject.CheckProperty(Sys.Process("DL.CODE").WPFObject("HwndSource: Window"), "WndCaption", cmpEqual, "Device Package Update"); 
                          Sys.Process("DL.CODE").WPFObject("HwndSource: Window").WPFObject("Window").WPFObject("Grid", "", 1).WPFObject("Grid", "", 2).WPFObject("ButtonPanel").WPFObject("btnYes").ClickButton();                       
                    } 
                    if (Sys.Process("DL.CODE").WPFObject("HwndSource: Shell", const_firmware).WPFObject("Shell", const_firmware, 1).WPFObject("Border", "", 1).WPFObject("DockPanel", "", 1).WPFObject("Grid", "", 2).WPFObject("BusyIndicator", "", 1).Visible == true)
                                aqObject.CheckProperty(Sys.Process("DL.CODE").WPFObject("HwndSource: Shell", const_firmware).WPFObject("Shell", const_firmware, 1).WPFObject("Border", "", 1).WPFObject("DockPanel", "", 1).WPFObject("Grid", "", 2).WPFObject("BusyIndicator", "", 1).WPFObject("TextBlock", "*", 1), "WPFControlText", cmpEqual, lib_label.const_UpdatingFirmware);
                    while (!Sys.Process("DL.CODE")["WaitWPFObject"]("HwndSource: Window", lib_const.const_delay_1000).Exists)
                                lib_const.const_delay_3000;
                    if (Sys.Process("DL.CODE").WaitWPFObject("HwndSource: Window", lib_const.const_delay_1000).Exists)
                    {                          
                          
                          var txt =  Sys.Process("DL.CODE").WPFObject("HwndSource: Window").WPFObject("Window").WPFObject("Grid", "", 1).WPFObject("Grid", "", 1).WPFObject("MessageText").WPFControlText;
                          if (txt == lib_label.const_DeviceRestart)
                          {
                                  aqObject.CheckProperty(Sys.Process("DL.CODE").WPFObject("HwndSource: Window").WPFObject("Window").WPFObject("Grid", "", 1).WPFObject("Grid", "", 1).WPFObject("MessageText"),"WPFControlText", cmpEqual, lib_label.const_DeviceRestart);                          
                                  Sys.Process("DL.CODE").WPFObject("HwndSource: Window").WPFObject("Window").WPFObject("Grid", "", 1).WPFObject("Grid", "", 2).WPFObject("ButtonPanel").WPFObject("btnOK").ClickButton();
                                  flag = lib_err.err_FUNC_SUCCESS; 
                                  Delay(80000);   
                          } 
                          if ( txt == lib_label.const_Device_Attention)       
                          {
                                  Log.Error(txt);
                                  Sys.Process("DL.CODE").WPFObject("HwndSource: Window").WPFObject("Window").WPFObject("Grid", "", 1).WPFObject("Grid", "", 2).WPFObject("ButtonPanel").WPFObject("btnOK").ClickButton();
                                  flag = lib_err.err_FUNC_FAILED; 
                                  lib_common.restartDevice(lib_deviceInfo.const_Device_IP_Adress);   
                                  Delay(80000);
                          }           
                    } 
                                      
             }
      }
      catch (e)  
      {
          return lib_err.err_FUNC_EXCEPTION;     
      }
      Log.PopLogFolder();  
      return flag;
}
// author: lhoang
function upgrade2(ip, deviceModel, serial)
{
 lib_common.launchUI();
 connectToDevice2(ip);
 lib_common.clickOnMenu("Device", "Update Package");
 GUIRevision = "DL.CODE " + aqString.SubString(LatestGUI, 0, 5);
 if(!SelectPackage(GUIRevision, deviceModel, LatestBuildSW_Version)) return;
 WaitingDone(serial, GUIRevision);
 verifyPackageAndLoader(ip, "DL.CODE " + LatestGUI, LatestBuildSW_Version, LatestLoader);
}
//author: lhoang
function openJobOnDevice2(jobName)
{
  var openJobBtn = Sys.Process("DL.CODE").FindChild("WPFControlText", "Open Device Configuration",1000);
  if(openJobBtn.Exists)
  { 
    openJobBtn.Click();
  }
  var openDevicePopup;
  while(true)
  {
    openDevicePopup = Sys.Process("DL.CODE").FindChild("ClrClassName", "JobListDialogWindow", 1000);
    if(openDevicePopup.Exists)
    {
      if(openDevicePopup.Visible)
      {
        break;
      }
    }
    delay(500);
  }
  jobItem = openDevicePopup.FindChild("WPFControlText", jobName, 1000);
  if(jobItem.Exists)
  {
    jobItem.Click();
  }
  arrPro = ["WPFControlText", "ClrClassName"];
  arrVal = ["OK", "Button"];
  okBtn = openDevicePopup.FindChild(arrPro, arrVal, 1000);
  okBtn.Click();
  delay(1000);
  if(Sys.Process("DL.CODE").WaitWPFObject("HwndSource: Window", 1000).Exists)
  {
    yesBtn = Sys.Process("DL.CODE").WPFObject("HwndSource: Window").FindChild("WPFControlName", "btnYes", 1000);
    yesBtn.Click();
  }
  while(true)
  {
    if(Sys.Process("DL.CODE").WPFObject("HwndSource: Shell", "DL.CODE*").Enabled)
    {
      break;
    }
    delay(3000);
  }
  delay(5000);
}

function mainDownGrade()
{
  downGrade(lib_deviceInfo.const_Device_IP_Adress, lib_deviceInfo.const_Device_SerialNumber)
}
// 18.11.2020
// starting with all new
// GUI_FW: 1.x.x.xx
function CheckIfGUIIsInstalled(GUI)
{
	var t = "DL.CODE x.x.x";
	var flag = false;
	var folderInstalled = aqString.SubString(GUI, 0, t.length);
	var pathGUI = lib_deviceInfo.datalogicInstalledFolder + folderInstalled;
	if(aqFile.Exists(pathGUI))
	{
		flag =  true;
	}
	else	
	{
	 flag =  false;
	}
}
function ChangeJobToDefaultBeforeDownGrade(deviceIP)
{
	lib_common.terminateUI();
	lib_common.launchUI();
	lib_common.connectToDevice(deviceIP);	
	lib_OpenJob.openOnDevice(lib_const.const_DefaultJob, lib_const.const_isDefaultJob_Y, lib_const.const_isOpenViaButton_Y);
	lib_common.gettingStarted();
	lib_common.terminateUI();	
}
function DowngradeUseLastOfficial(lastOfficialPath, deviceIP, model, serialNumber)
{
	var currentTestAppDLCODE = TestedApps.DL_CODE.Path;
	TestedApps.DL_CODE.Path = lastOfficialPath;
	lib_common.launchUI();
	connectToDevice2(deviceIP);
	var flag = ProcessDownGrade(model, serialNumber);
	TestedApps.DL_CODE.Path = currentTestAppDLCODE;
	return flag;
}

function CreateConfigurationForUpdate(lastOfficialPath, configure)
{
	var currentTestAppDLCODE = TestedApps.DL_CODE.Path;
	TestedApps.DL_CODE.Path = lastOfficialPath;
	lib_common.launchUI();
	connectToDevice2(deviceIP);
	lib_OpenJob.openOnDevice(lib_const.const_DefaultJob, lib_const.const_isDefaultJob_Y, lib_const.const_isOpenViaButton_Y);
	lib_button.clickAdvancedSetup();
	if(configure.codes.code1 == "" && configure.codes.code2 == "")
	{
		
	}
	else
	{
		lib_button.clickDeleteCode()
	}
}
function test()
{
	
}