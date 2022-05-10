reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /f /v DefaultUserName /d ft
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /f /v DefaultPassword /d $args[0]
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /f /v AutoAdminLogon /d "1"
wmic UserAccount set PasswordExpires=False
