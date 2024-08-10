$profile_dir = Split-Path $profile

Import-Module posh-git
Invoke-Expression (&starship init powershell)

# ---------- 補完表示設定 ----------
Set-PSReadLineOption -PredictionSource History -PredictionViewStyle ListView
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

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
#kubectl completion powershell | Out-String | Invoke-Expression"
. "$profile_dir\kubectl.ps1"

Set-Alias -Name: k -Value: kubectl
# kもkubectlの補完を使う
Register-ArgumentCompleter -CommandName 'k' -ScriptBlock $__kubectlCompleterBlock

if (Get-Command flux -ea SilentlyContinue) {
    #flux completion powershell | Out-String | Invoke-Expression;
    . "$profile_dir\fluxcd.ps1"
}

if (Get-Command helm -ea SilentlyContinue) {
    #helm completion powershell | Out-String | Invoke-Expression;
    . "$profile_dir\helm.ps1"
}

if (Get-Command docker -ea SilentlyContinue) {
    #docker completion powershell | Out-String | Invoke-Expression;
    . "$profile_dir\docker.ps1"
}

# ---------- eza ----------
if (Get-Command eza -ea SilentlyContinue) {
    Remove-Alias -Name: "ls"

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
}
# --------------------

# ---------- ghq & peco ----------
function ghqcd() {
    $repository = $(ghq list | peco)
    $repositoryPath = (ghq root) + '/' + $repository
    Set-Location $repositoryPath
}

# ---------- go install ----------
function GoInstall() {
    Param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Package,
        [Parameter(Mandatory = $false, Position = 1)]
        [string]$Version = "latest"
    )

    $command_name = [System.IO.Path]::GetFileNameWithoutExtension($Package)
    if (!(Get-Command $command_name -ea SilentlyContinue)) {
        go install $Package@$Version
    }
}

GoInstall -Package "github.com/mattn/kubectl-finalize_namespace"
GoInstall -Package "github.com/x-motemen/ghq"
GoInstall -Package "github.com/google/wire/cmd/wire"
GoInstall -Package "github.com/stern/stern"
GoInstall -Package "github.com/nao1215/gup"

# ---------- エイリアス ----------
## --------- エイリアスutil ----------
function SafeSetAlias {
    Param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Alias,
        [Parameter(Mandatory = $true, Position = 1)]
        [string[]]$Command
    )

    foreach ($cmd in $Command) {
        # 空白を含んでいたら関数として定義
        if ($Command -match "\s") {
            $func = "function global:$Alias { $Command }"
            Invoke-Expression $func
            return
        }
        # それ以外はAlias
        else {
            if (Get-Command $cmd -ea SilentlyContinue) {
                Set-Alias -Name: $Alias -Value: $cmd -Scope: Global
                break
            }
        }
    }
}

Set-Alias -Name: "open" -Value: "explorer"
SafeSetAlias -Alias "pbcopy" -Command "Set-Clipboard"
SafeSetAlias -Alias "export" -Command "set"
SafeSetAlias -Alias "wget" -Command "wget2"
SafeSetAlias -Alias "grep" -Command "ugrep", "grep", "Select-String"
SafeSetAlias -Alias "htop" -Command "btm -b"

function Invoke-Starship-TransientFunction {
    &starship module character
}
  
Invoke-Expression (&starship init powershell)
  
Enable-TransientPrompt

$env:KUBE_EDITOR = "code -w"


#f45873b3-b655-43a6-b217-97c00aa0db58 PowerToys CommandNotFound module

Import-Module -Name Microsoft.WinGet.CommandNotFound
#f45873b3-b655-43a6-b217-97c00aa0db58
