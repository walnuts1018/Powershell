$ErrorActionPreference = "SilentlyContinue"
$profile_dir = Split-Path $profile

Import-Module posh-git
oh-my-posh init pwsh --config $profile_dir/.pwsh10k.omp.json | Invoke-Expression


Set-PSReadLineOption -PredictionSource History -PredictionViewStyle ListView

Set-Alias -Name: "open" -Value: "explorer"
Set-Alias -Name: "grep" -Value: "Select-String"
Set-Alias -Name: "pbcopy" -Value: "Set-Clipboard"

Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
    $Local:word = $wordToComplete.Replace('"', '""')
    $Local:ast = $commandAst.ToString().Replace('"', '""')
    winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}


Set-Alias -Name: k -Value: kubectl
Register-ArgumentCompleter -CommandName 'k' -ScriptBlock $__kubectlCompleterBlock

kubectl completion powershell | Out-String | Invoke-Expression
flux completion powershell | Out-String | Invoke-Expression
helm completion powershell | Out-String | Invoke-Expression

Remove-Alias -Name: "ls"

function ls {
    $paths = @()

    $rawoptions = @()
    $options = @()
    
    $prefix = @()
    $saffix = @()

    foreach ($a in $args) {
        if ($a.StartsWith("-") -And !($a.StartsWith("--"))) {
            $tmp = $a.ToCharArray()
            $rawoptions += $tmp[0..($tmp.length - 1)]
        }
        elseif ($a.StartsWith("--")) {
            #TODO
        }
        else {
            $paths += $a
        }
    }

    $rawoptions = $rawoptions | Select-Object -Unique
    foreach ($o in $rawoptions) {
        switch ($o) {
            #show hidden files
            "a" { $options += "-Force" }
        }
    }

    #show hidden files & dot files
    if ($rawoptions -contains "a") {}
    else {
        $saffix += '| Where-Object { $_.Name -NotMatch "^\." }'
    }

    #sort by size
    if ($rawoptions -contains "S") {
        $saffix += "| Sort-Object -Property Length -Descending"
    }

    #show file size in KB
    if ($rawoptions -contains "h") {
        $prefix += '$result = New-Object -TypeName PSObject -Property @{Mode = "Mode"; LastWriteTime = "LastWriteTime"; Length = "Length"; Name = "Name" };'
        $saffix += '|ForEach-Object {$result.Mode = $_.Mode; $result.LastWriteTime = $_.LastWriteTime; $result.Length = [string]([Math]::Round($_.Length/1024, 1, [MidpointRounding]::AwayFromZero))+"K"; $result.Name = $_.Name; $result}'
    }

    #show long format
    if ($rawoptions -contains "l") {
        $saffix += "| Format-Table Mode,LastWriteTime,Length,Name" 
    }
    else {
        $saffix += "| Select-Object Name | Format-Wide -AutoSize"
    }

    $command = "$($prefix -join " ") Get-ChildItem $($options -join " ") $($paths -join " ") $($saffix -join " ")"
    #write-host $command
    $command | Invoke-Expression
}

$ErrorActionPreference = "Continue"
