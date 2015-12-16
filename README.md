# GetAccessMask_WPF

Running this will launch a Windows Form (GUI Interface).  The form will allow you to select specific security options that are available on all Windows Security Tabs.

Once selected, clicking the "Get Access Mask" button will produce another form, providing you with the Access Mask that matches the security options you specified.  This new form allows you to copy the mask to your clipboard with the "Copy To Clipboard" button.

## Screenshots

![alt tag](https://raw.githubusercontent.com/terrytrent/GetAccessMask_WPF/master/Screenshots/MainForm.png)

<sup>*The Main Form*</sup>

![alt tag](https://raw.githubusercontent.com/terrytrent/GetAccessMask_WPF/master/Screenshots/MainForm_NoSecurityOptions.PNG)

<sup>*This comes up if you have not selected any security options*</sup>

![alt tag](https://raw.githubusercontent.com/terrytrent/GetAccessMask_WPF/master/Screenshots/MainForm_AccessMask_FullControl.png)

<sup>*When you select Full Control -or- every checkbox -or- every checkbox except for Full Control, you will always get this Access Mask*</sup>

![alt tag](https://raw.githubusercontent.com/terrytrent/GetAccessMask_WPF/master/Screenshots/MainForm_AccessMask_LimitedPermissions.png)

<sup>*This is an example of limited permission - the Access Mask has been calculated based off what was selected*</sup>
