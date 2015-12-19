# Initialize Assemblies
Add-Type -AssemblyName PresentationFramework,system.windows.forms,System.Drawing

$pwd=(get-location).Path

# Set permissions to cycle through
$permissions=@(
"cb_FullControl",
"cb_TraverseFolder_ExecuteFile",
"cb_ListFolder_ReadData",
"cb_ReadAttributes",
"cb_ReadExtendedAttributes",
"cb_CreateFiles_WriteData",
"cb_CreateFolders_AppendData",
"cb_WriteAttributes",
"cb_WriteExtendedAttributes",
"cb_DeleteSubfoldersAndFiles",
"cb_Delete",
"cb_ReadPermissions",
"cb_ChangePermissions",
"cb_TakeOwnership"
)
# Function for clearing and setting the clipboard contents
function Set-Clipboard(){

    Param (

        $content

    )

    [Windows.Forms.Clipboard]::Clear()
    sleep .5
    [Windows.Forms.Clipboard]::SetText($content)

}
# Function for creating message box
function New-MessageBox(){
<#

    .SYNOPSIS

    Generates Closing Message Boxes - first confiming the close, second confirming you have chosen not to close.

    Icon Codes:

        Asterisk............The message box contains a symbol consisting of a lowercase letter i in a circle.
        Error...............The message box contains a symbol consisting of white X in a circle with a red background.
        Exclamation.........The message box contains a symbol consisting of an exclamation point in a triangle with a yellow background.
        Hand................The message box contains a symbol consisting of a white X in a circle with a red background.
        Information.........The message box contains a symbol consisting of a lowercase letter i in a circle.
        None................The message box contain no symbols.
        Question............The message box contains a symbol consisting of a question mark in a circle. The question-mark message icon
                            is no longer recommended because it does not clearly represent a specific type of message and because the
                            phrasing of a message as a question could apply to any message type. In addition, users can confuse the
                            message symbol question mark with Help information. Therefore, do not use this question mark message symbol
                            in your message boxes. The system continues to support its inclusion only for backward compatibility.
        Stop................The message box contains a symbol consisting of white X in a circle with a red background.
        Warning.............The message box contains a symbol consisting of an exclamation point in a triangle with a yellow background.


    Button Codes:

        AbortRetryIgnore....The message box contains Abort, Retry, and Ignore buttons.
        OK..................The message box contains an OK button.
        OKCancel............The message box contains OK and Cancel buttons.
        RetryCancel.........The message box contains Retry and Cancel buttons.
        YesNo...............The message box contains Yes and No buttons.
        YesNoCancel	........The message box contains Yes, No, and Cancel buttons.

#>
    Param (

        $message,
        $title,
        $icon,
        $buttons
    )

    $messageBox = [System.Windows.Forms.MessageBox]::Show($message , $title , $buttons, $icon)
    return $messageBox

}
# Function for calculating the Access Mask, displaying it, and allowing copy to clipboard
function Get-AccessMask(){
    # Default Access Mask is the Sync ACL, a part of all default ACLs
    $AccessMask=1048576

    # Check if "Full Control" was checked, if so ignore all other settings and provide the mask for Full Control
    if($script:cb_FullControl.IsChecked -eq $true){
        $AccessMask=2032127
    }
    else{
        # Cycle through permissions
        foreach($p in $permissions){
            # Store checked value of specific permission
            $permissionChecked=$(Get-Variable -Name $p -ValueOnly).ischecked

            # If value is checked add its specific value to the Access Mask
            if($permissionChecked -eq $true){

                switch($p){

                    "cb_TraverseFolder_ExecuteFile" {$AccessMask+=32}
                    "cb_ListFolder_ReadData" {$AccessMask+=1}
                    "cb_ReadAttributes" {$AccessMask+=128}
                    "cb_ReadExtendedAttributes" {$AccessMask+=8}
                    "cb_CreateFiles_WriteData" {$AccessMask+=2}
                    "cb_CreateFolders_AppendData" {$AccessMask+=4}
                    "cb_WriteAttributes" {$AccessMask+=256}
                    "cb_WriteExtendedAttributes" {$AccessMask+=16}
                    "cb_DeleteSubfoldersAndFiles" {$AccessMask+=64}
                    "cb_Delete" {$AccessMask+=65536}
                    "cb_ReadPermissions" {$AccessMask+=131072}
                    "cb_ChangePermissions" {$AccessMask+=262144}
                    "cb_TakeOwnership" {$AccessMask+=524288}
                }
            }
        }
    }

    if($AccessMask -eq "1048576"){
        New-MessageBox -message "You have not selected any Security Options.`n`nPlease select Security Options to continue." -title "No Security Options Selected" -icon "Stop" -buttons "OK"
    }
    else{
        # Set the Access Mask Variable on the Script Scope
        $script:AccessMask=$AccessMask

        # Create the Results Form
        $resultsxaml = [XML](Get-Content “.\Assets\GAMResults.xaml”)
        $resultsxamlReader = New-Object System.Xml.XmlNodeReader $resultsxaml
        $resultsform = [Windows.Markup.XamlReader]::Load($resultsxamlReader)
    
        # Set the results form to be a child of the main form
        $resultsform.owner=$mainform

        # Map the variables to the objects in the xaml file
        $lbl_AccessMask=$resultsform.FindName('lbl_AccessMask')
        $btn_CopyToClipboard=$resultsform.FindName('btn_CopyToClipboard')
        $btn_Close=$resultsform.FindName('btn_Close')

        # Specify the values and actions of the objects in the xaml file
        $lbl_AccessMask.Content=$AccessMask
        $btn_Close.add_click({$resultsform.close()})
        $btn_CopyToClipboard=(Set-Clipboard -content $AccessMask)

        # Specify icon for the Results form (icon variable created in the main form)
        $resultsform.icon=$iconBitmap

        # Show the Results form
        [void]$resultsform.ShowDialog()
    }

}
# Function to clear all checkboxes
function Clear-CheckBoxes(){

    foreach($p in $permissions){

        (Get-Variable -Name $p -ValueOnly).IsChecked=$false

    }

}
# Function to check all but "Full Control"
function Check-AllCheckBoxes(){

    foreach($p in $permissions){

        (Get-Variable -Name $p -ValueOnly).IsChecked=$true
    }

}


# Create the Main Form
$xaml = [XML](Get-Content “.\Assets\GAMMain.xaml”)
$xamlReader = New-Object System.Xml.XmlNodeReader $xaml
$mainform = [Windows.Markup.XamlReader]::Load($xamlReader)

# Create icon object
$icon=New-Object System.Drawing.Icon ("$pwd\Assets\mask.ico")
# Convert icon object to base64
$iconBase64=[convert]::ToBase64String($icon)

# Create and store the icon as bitmap
$iconBitmap = New-Object System.Windows.Media.Imaging.BitmapImage
$iconBitmap.BeginInit()
$iconBitmap.StreamSource = [System.IO.MemoryStream][System.Convert]::FromBase64String($iconBase64)
$iconBitmap.EndInit()
$iconBitmap.Freeze()

# Set icon
$mainform.icon=$iconBitmap

# Show form in taskbar
$mainform.ShowInTaskbar=$true

# Define Form Elements
$cb_FullControl=$mainform.FindName('cb_FullControl')
$cb_TraverseFolder_ExecuteFile=$mainform.FindName('cb_TraverseFolder_ExecuteFile')
$cb_ListFolder_ReadData=$mainform.FindName('cb_ListFolder_ReadData')
$cb_ReadAttributes=$mainform.FindName('cb_ReadAttributes')
$cb_ReadExtendedAttributes=$mainform.FindName('cb_ReadExtendedAttributes')
$cb_CreateFiles_WriteData=$mainform.FindName('cb_CreateFiles_WriteData')
$cb_CreateFolders_AppendData=$mainform.FindName('cb_CreateFolders_AppendData')
$cb_WriteAttributes=$mainform.FindName('cb_WriteAttributes')
$cb_WriteExtendedAttributes=$mainform.FindName('cb_WriteExtendedAttributes')
$cb_DeleteSubfoldersAndFiles=$mainform.FindName('cb_DeleteSubfoldersAndFiles')
$cb_Delete=$mainform.FindName('cb_Delete')
$cb_ReadPermissions=$mainform.FindName('cb_ReadPermissions')
$cb_ChangePermissions=$mainform.FindName('cb_ChangePermissions')
$cb_TakeOwnership=$mainform.FindName('cb_TakeOwnership')
$btn_GetAccessMask=$mainform.FindName('btn_GetAccessMask')
$btn_Close=$mainform.FindName('btn_Close')
$btn_ClearAll=$mainform.FindName('btn_ClearAll')
$btn_CheckAll=$mainform.FindName('btn_CheckAll')

# Define Button Actions
$btn_GetAccessMask.Add_Click({Get-AccessMask})
$btn_Close.Add_Click({$mainform.close()})
$btn_CheckAll.Add_Click({Check-AllCheckBoxes})
$btn_ClearAll.Add_Click({Clear-CheckBoxes})

# Show the form
[void]$mainform.ShowDialog()

