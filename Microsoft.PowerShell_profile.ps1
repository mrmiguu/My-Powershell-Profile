Function Prompt {
  RefreshScripts
  $host.UI.RawUI.WindowTitle = (Get-Item -Path ".\" -Verbose).Name
  "PS $(Get-Location)> "
}

Function StartPowershell($dir) {
  $dirs = Resolve-Path $dir
  $fst = Get-Location
  foreach ($d in $dirs) {
    Set-Location $d
    Start-Process powershell
    Set-Location $fst
  }
}

Function RefreshScripts {
  Import-Module $profile -Force
}

function Set-WindowStyle {
param(
    [Parameter()]
    [ValidateSet('FORCEMINIMIZE', 'HIDE', 'MAXIMIZE', 'MINIMIZE', 'RESTORE', 
                 'SHOW', 'SHOWDEFAULT', 'SHOWMAXIMIZED', 'SHOWMINIMIZED', 
                 'SHOWMINNOACTIVE', 'SHOWNA', 'SHOWNOACTIVATE', 'SHOWNORMAL')]
    $Style = 'SHOW',
    [Parameter()]
    $MainWindowHandle = (Get-Process -Id $pid).MainWindowHandle
)
    $WindowStates = @{
        FORCEMINIMIZE   = 11; HIDE            = 0
        MAXIMIZE        = 3;  MINIMIZE        = 6
        RESTORE         = 9;  SHOW            = 5
        SHOWDEFAULT     = 10; SHOWMAXIMIZED   = 3
        SHOWMINIMIZED   = 2;  SHOWMINNOACTIVE = 7
        SHOWNA          = 8;  SHOWNOACTIVATE  = 4
        SHOWNORMAL      = 1
    }
    Write-Verbose ("Set Window Style {1} on handle {0}" -f $MainWindowHandle, $($WindowStates[$style]))

    $Win32ShowWindowAsync = Add-Type –memberDefinition @" 
    [DllImport("user32.dll")] 
    public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
"@ -name "Win32ShowWindowAsync" -namespace Win32Functions –passThru

    $Win32ShowWindowAsync::ShowWindowAsync($MainWindowHandle, $WindowStates[$Style]) | Out-Null
}

Function Here($emptyBodyOrFile, $emptyFileOrBody, $newFile) {
  $PSDefaultParameterValues["*:Encoding"] = "utf8"

  if ($emptyBodyOrFile -eq $null) {
    Set-Clipboard $null
    [System.Windows.Forms.SendKeys]::SendWait("here @'")
  } elseif (Test-Path ($emptyBodyOrFile -replace "`r`n|`n", $null)) {
    if ($emptyFileOrBody -eq $null) {
      Get-Content $emptyBodyOrFile | Set-Clipboard
      [System.Windows.Forms.SendKeys]::SendWait("here $emptyBodyOrFile @'")
    } else {
      if ($newFile -eq $null) {
        Write-Output $emptyFileOrBody
        return
      } else {
        $emptyFileOrBody | Out-FileUtf8NoBom $newFile
        return
      }
    }
  } else {
    if ($emptyFileOrBody -eq $null) {
      Write-Output $emptyBodyOrFile
      return
    } else {
      $emptyBodyOrFile | Out-FileUtf8NoBom $emptyFileOrBody
      return
    }
  }

  [System.Windows.Forms.SendKeys]::SendWait("~")
  [System.Windows.Forms.SendKeys]::SendWait("^{v}")
}

Set-Alias reload RefreshScripts
Set-Alias sps StartPowershell
Set-Alias fs FindStr

Set-WindowStyle MAXIMIZE
