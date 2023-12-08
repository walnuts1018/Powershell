$profile_dir=Split-Path $profile

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
kubectl completion powershell | Out-String | Invoke-Expression
Register-ArgumentCompleter -CommandName 'k' -ScriptBlock $__kubectlCompleterBlock

flux completion powershell | Out-String | Invoke-Expression
helm completion powershell | Out-String | Invoke-Expression

