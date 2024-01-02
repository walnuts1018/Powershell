$profile_dir = Split-Path $profile

Import-Module posh-git
oh-my-posh init pwsh --config $profile_dir/.pwsh10k.omp.json | Invoke-Expression

Set-PSReadLineOption -PredictionSource History -PredictionViewStyle ListView
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

Set-Alias -Name: "open" -Value: "explorer"
Set-Alias -Name: "pbcopy" -Value: "Set-Clipboard"

# ugrep存在確認
if (Get-Command ugrep -ea SilentlyContinue) {
    Set-Alias -Name: "grep" -Value: "ugrep"
}
else {                                
    Set-Alias -Name: "grep" -Value: "Select-String"
}

Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
    $Local:word = $wordToComplete.Replace('"', '""')
    $Local:ast = $commandAst.ToString().Replace('"', '""')
    winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

kubectl completion powershell | Out-String | Invoke-Expression
flux completion powershell | Out-String | Invoke-Expression
helm completion powershell | Out-String | Invoke-Expression

Set-Alias -Name: k -Value: kubectl
Register-ArgumentCompleter -CommandName 'k' -ScriptBlock $__kubectlCompleterBlock


# ------------------- eza -------------------
# eza存在確認
if (Get-Command eza -ea SilentlyContinue) {
    Remove-Alias -Name: "ls"
}

function ls() {
    eza --git -@ -g -mU --icons --time-style=long-iso --color=automatic --group-directories-first $args
}

function ll() {
    ls -lh # Long format, git status
}
function l() {
    ll -a # Long format, all files
}
function lr() {
    ls -Tlh # Long format, recursive as a tree
}
function lx() {
    ll -sextension # Long format, sort by extension
}
function lk() {
    ll -ssize # Long format, largest file size last
}
function lt() {
    ll -smodified # Long format, newest modification time last
}
function lc() {
    ll -schanged # Long format, newest status change (ctime) last
}
function tree() {
    ls -Tl --no-permissions --no-filesize --no-user --no-time
}
