$SCRIPT_PATH = Split-Path -Parent $MyInvocation.MyCommand.Definition

$C_OFF = "`e[0m"
$C_ERROR = "`e[0;31m"
$C_WARN = "`e[0;33m"

# Check Build image's existence
if ("$(docker images -q ubuntu-enhanced)" -eq "") {
    Write-Host "${C_WARN}WARNING: ubuntu-enhanced does not exist.${C_OFF}"
    $opt = Read-Host "Build it first? (y/n) [y]"
    if ($opt -eq "") {
        $opt = "y"
    }
} else {
    Write-Host "${C_WARN}WARNING: ubuntu-enhanced already exist.${C_OFF}"
    $opt = Read-Host "Build it again? (y/n) [n]"
    if ($opt -eq "") {
        $opt = "n"
    }
}

if ($opt -eq "y") {
    Write-Host "INFO: Trying to build ubuntu-enhanced"
    & "$SCRIPT_PATH/build.ps1"
} elseif ("$(docker images -q ubuntu-enhanced)" -eq "") {
    Write-Host "${C_ERROR}ERROR: ubuntu-enhanced not exist!${C_OFF}"
    exit 1
} else {
    Write-Host "INFO: Skipping build."
}

# Get run parameters
Write-Host "INFO: Setting up parameters:"
$args = "-d "

while (-not $NAME) {
    $NAME = Read-Host "- Container Name"
}
$args += "--name '$NAME' "

$ROOT_PASSWORD = Read-Host "- Root Password [<RANDOM_VALUE>]"
if ($ROOT_PASSWORD) {
    $args += "-e ROOT_PASSWORD='$ROOT_PASSWORD' "
}

$opt = Read-Host "- SSH Authorized Key (file/str) [str]"
if ([string]::IsNullOrEmpty($opt)) {
    $opt = "str"
}
if ($opt -eq "str") {
    $AUTHORIZED_KEY = Read-Host "  + Public Key ['']"
}
elseif ($opt -eq "file") {
    $AUTHORIZED_KEY_PATH = Read-Host "  + Public Key Path [~/.ssh/id_rsa.pub]"
    if ([string]::IsNullOrEmpty($AUTHORIZED_KEY_PATH)) {
        $AUTHORIZED_KEY_PATH = "~/.ssh/id_rsa.pub"
    }
    $AUTHORIZED_KEY = Get-Content $AUTHORIZED_KEY_PATH -ErrorAction SilentlyContinue
}
if (![string]::IsNullOrEmpty($AUTHORIZED_KEY)) {
    $args += "-e AUTHORIZED_KEY='$AUTHORIZED_KEY' "
}

$TZ = Read-Host "- Timezone [Asia/Shanghai]"
if ($TZ) {
    $args += "-e TZ='$TZ' "
}

$PORT = Read-Host "- Exposed Port [2233]"
if ($PORT) {
    $args += "-p $PORT:22 "
} else {
    $args += "-p 2233:22 "
}

$OPP = Read-Host "- Other Parameters (example:'--gpus all') ['']"
if ($OPP) {
    $args += "$OPP "
}

Write-Host "INFO: Docker args: $args"

Read-Host "Press anything to run."

Invoke-Expression "docker run $args ubuntu-enhanced"