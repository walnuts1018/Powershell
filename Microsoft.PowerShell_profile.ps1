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
    $rawoptions = @()
    $paths = @()
    write-host $args
    foreach ($a in $args) {
        if ($a.StartsWith("-") -And !($a.StartsWith("--"))) {
            $rawoptions += $a.ToCharArray()[1..-1]
        }
        elseif ($a.StartsWith("--")) {
            #TODO
        }
        else {
            $paths += $a
        }
    }
    $rawoptions = $rawoptions | Select-Object -Unique
    $options = @()

    foreach ($o in $rawoptions) {
        switch ($o) {
            "a" { $options += "-Force" }
        }
    }

    $command = ""
    if (($rawoptions -contains "l")) {
        $command = "Get-ChildItem $($options -join " ") $($paths -join " ")"
    }
    else {
        $command = "Get-ChildItem $($options -join " ") $($paths -join " ") | Format-Wide -Column 5"
    }
    $command | Invoke-Expression
}

$ErrorActionPreference = "Continue"
