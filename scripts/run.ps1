$SCRIPT_PATH=Split-Path -Parent $MyInvocation.MyCommand.Path

$C_INFO=[ConsoleColor]::Blue
$C_WARN=[ConsoleColor]::Yellow
$C_ERROR=[ConsoleColor]::Red

# Specify Ubuntu Version
Write-Host -ForegroundColor $C_INFO "INFO: Preparing ubuntu-enhanced image:"
$version = Read-Host "  - Ubuntu Version [latest]"

# Ensure Build image's existence
if (-not $version) {
    $version="latest"
}

if ("$(docker images -q "ubuntu-enhanced:$version" 2>$null)" -eq "") {
    Write-Host -ForegroundColor $C_WARN "WARNING: ubuntu-enhanced:$version does not exist."
    $opt = Read-Host "  - Build it first? (y/n) [y]"
    if (-not $opt) {
        $opt="y"
    }
    if ($opt -ne "y") {
        Write-Host -ForegroundColor $C_ERROR "ERROR: ubuntu-enhanced:$version not exist!"
        exit 1
    }
}
else {
    Write-Host -ForegroundColor $C_WARN "WARNING: ubuntu-enhanced:$version already exist."
    $opt = Read-Host "  - Build it again? (y/n) [n]"
    if (-not $opt) {
        $opt="n"
    }
}

if ($opt -eq "y") {
    Write-Host -ForegroundColor $C_INFO "INFO: Trying to build ubuntu-enhanced:$version"
    & "$SCRIPT_PATH/build.ps1" --version $version
}
else {
    Write-Host -ForegroundColor $C_WARN "WARNING: Skipping build..."
}

# Get run parameters
Write-Host -ForegroundColor $C_INFO "INFO: Setting up parameters:"
$args = "-d "

while (-not $NAME) {
    $NAME = Read-Host "  - Container Name"
}
$args += "--name '$NAME' "

$ROOT_PASSWORD = Read-Host "  - Root Password [<RANDOM_VALUE>]"
if ($ROOT_PASSWORD) {
    $args += "-e ROOT_PASSWORD='$ROOT_PASSWORD' "
}

$opt = Read-Host "  - SSH Authorized Key (file/str) [str]"
if (-not $opt) {
    $opt = "str"
}
if ($opt -eq "str") {
    $AUTHORIZED_KEY = Read-Host "    + Public Key ['']"
}
elseif ($opt -eq "file") {
    $AUTHORIZED_KEY_PATH = Read-Host "    + Public Key Path [~/.ssh/id_rsa.pub]"
    if (-not $AUTHORIZED_KEY_PATH) {
        $AUTHORIZED_KEY_PATH = "~/.ssh/id_rsa.pub"
    }
    $AUTHORIZED_KEY = Get-Content $AUTHORIZED_KEY_PATH -ErrorAction SilentlyContinue
}
if ($AUTHORIZED_KEY) {
    $args += "-e AUTHORIZED_KEY='$AUTHORIZED_KEY' "
}

$TZ = Read-Host "  - Timezone [Asia/Shanghai]"
if ($TZ) {
    $args += "-e TZ='$TZ' "
}

$PORT = Read-Host "  - Exposed Port [2233]"
if ($PORT) {
    $args += "-p $PORT:22 "
} else {
    $args += "-p 2233:22 "
}

$OPP = Read-Host "  - Other Parameters (example:'--gpus all') ['']"
if ($OPP) {
    $args += "$OPP "
}

Write-Host -ForegroundColor $C_INFO "INFO: Docker command:"
Write-Host "  - docker run $args ubuntu-enhanced:$version"

Read-Host "Press anything to run"

Invoke-Expression "docker run $args ubuntu-enhanced:$version"