$profile_dir = Split-Path $profile

Import-Module PSReadLine;

function slowJobs() {
    Import-Module posh-git;
}

function prompt {
    if ((Test-Path variable:global:slowInvokeJobs) -or (Test-Path variable:global:slowjob)) {
        for ($i = 0; $i -lt $global:slowInvokeJobs.Count; $i++) {
            Receive-Job -Wait -AutoRemoveJob -Job $global:slowInvokeJobs[$i] | Invoke-Expression;
        } 
        Receive-Job -Wait -AutoRemoveJob -Job $global:slowjob;
        
        Remove-Variable slowInvokeJobs -Scope Global;
        Remove-Variable slowjob -Scope Global;

        return prompt;
    }
    $global:slowInvokeJobs = @();
    $global:slowInvokeJobs += Start-Job { param ([string]$profile_dir) (@(& 'C:/Users/juglans/AppData/Local/Programs/oh-my-posh/bin/oh-my-posh.exe' init pwsh --config="$profile_dir\.pwsh10k.omp.json" --print) -join "`n") } -ArgumentList $profile_dir;
    #$global:slowInvokeJobs += Start-Job { flux completion powershell | Out-String };
    #$global:slowInvokeJobs += Start-Job { helm completion powershell | Out-String };

    $global:slowjob = Start-Job { slowJobs };
    
    Write-Host -ForegroundColor Blue "Loading `$profile in the background..."
    Write-Host -ForegroundColor Green -NoNewline "  $($executionContext.SessionState.Path.CurrentLocation) ".replace($HOME, '~');
    Write-Host -ForegroundColor Red -NoNewline ">"
    return " ";
}

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
Set-Alias -Name: k -Value: kubectl
Register-ArgumentCompleter -CommandName 'k' -ScriptBlock $__kubectlCompleterBlock

flux completion powershell | Out-String | Invoke-Expression
helm completion powershell | Out-String | Invoke-Expression

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
