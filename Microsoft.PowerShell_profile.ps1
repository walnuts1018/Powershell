$profile_dir = Split-Path $profile

# ---------- 遅延読み込み ----------
function slowJobs() {
    Import-Module posh-git;
}

function prompt {
    if (Test-Path variable:global:ompjob) {
        Receive-Job -Wait -AutoRemoveJob -Job $global:ompjob | Invoke-Expression;
        Receive-Job -Wait -AutoRemoveJob -Job $global:slowjob;
        Remove-Variable ompjob -Scope Global;
        Remove-Variable slowjob -Scope Global;
        return prompt;
    }
    $global:ompjob = Start-Job { param ([string]$profile_dir) (@(& 'C:/Users/juglans/AppData/Local/Programs/oh-my-posh/bin/oh-my-posh.exe' init pwsh --config="$profile_dir\.pwsh10k.omp.json" --print) -join "`n") } -ArgumentList $profile_dir;
    $global:slowjob = Start-Job { slowJobs };
    
    Write-Host -ForegroundColor Blue "Loading `$profile in the background..."
    Write-Host -ForegroundColor Green -NoNewline "  $($executionContext.SessionState.Path.CurrentLocation) ".replace($HOME, '~');
    Write-Host -ForegroundColor Red -NoNewline ">"
    return " ";
}

# ---------- 補完表示設定 ----------
Import-Module PSReadLine;
Set-PSReadLineOption -PredictionSource History -PredictionViewStyle ListView
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# ---------- エイリアス ----------
Set-Alias -Name: "open" -Value: "explorer"
Set-Alias -Name: "pbcopy" -Value: "Set-Clipboard"
Set-Alias -Name: "export" -Value: "set"
Set-Alias -Name: "wget" -Value: "Invoke-WebRequest"

# ---------- ugrep ----------
# ugrep存在確認
if (Get-Command ugrep -ea SilentlyContinue) {
    Set-Alias -Name: "grep" -Value: "ugrep"
}
else {                                
    Set-Alias -Name: "grep" -Value: "Select-String"
}

# ---------- wingetタブ補完 ----------
Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
    $Local:word = $wordToComplete.Replace('"', '""')
    $Local:ast = $commandAst.ToString().Replace('"', '""')
    winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

# ---------- kubeタブ補完 ----------
kubectl completion powershell | Out-String | Invoke-Expression
Set-Alias -Name: k -Value: kubectl
# kもkubectlの補完を使う
Register-ArgumentCompleter -CommandName 'k' -ScriptBlock $__kubectlCompleterBlock
if (Get-Command flux -ea SilentlyContinue) {
    flux completion powershell | Out-String | Invoke-Expression;
}

if (Get-Command helm -ea SilentlyContinue) {
    helm completion powershell | Out-String | Invoke-Expression;
}

# ---------- eza ----------
# eza存在確認
if (Get-Command eza -ea SilentlyContinue) {
    Remove-Alias -Name: "ls"
}

function ls() {
    eza --git -@ -g -mU --icons --time-style=long-iso --color=automatic --group-directories-first --hyperlink -h $args
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
# --------------------
