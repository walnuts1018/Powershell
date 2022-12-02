Set-Alias nano "C:\Program Files(user)\nano"

Set-Alias kubectl "C:\Program Files(user)\kubectl"

Set-Alias iperf3 "C:\Program Files(user)\iperf-3.1.3-win64\iperf3.exe"

#Set-Alias vim "nvim"

Import-Module posh-git
oh-my-posh init pwsh --config ~/.pwsh10k.omp.json | Invoke-Expression

function Invoke-As-Admin() {
    if ($args.count -eq 0) {
        gsudo
        return
    }
    $cmd = $args -join ' '
    gsudo "pwsh.exe -Login -Command { $cmd }"
}

Set-Alias -Name: "sudo" -Value: "Invoke-As-Admin"
