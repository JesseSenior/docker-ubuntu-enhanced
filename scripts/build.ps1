if ($args[0] -eq "--version" -and $args[1]) {
    $VERSION = $args[1]
    docker build -t ubuntu-enhanced:latest $PSScriptRoot/.. --build-arg version=$VERSION
} else {
    docker build -t ubuntu-enhanced:latest $PSScriptRoot/..
}