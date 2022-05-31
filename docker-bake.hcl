group "default" {
    targets = [
        "latest"
    ]
}

group "all" {
    targets = [
	"32"
    ]
}

group "latest" {
    targets = [
        "32"
    ]
}

target "32" {
    platforms = ["linux/amd64"]
    dockerfile = "Dockerfile"
    tags = [
        "toxzcp/android-devcontainer:32",
        "toxzcp/android-devcontainer:latest"
    ]
    args = {
        UBUNTU_VERSION = "22.04"
        ANDROID_SDK_TOOLS_VERSION = "8512546"
        ANDROID_PLATFORM_VERSION = "32"
        ANDROID_BUILD_TOOLS_VERSION = "32.0.0"
    }
}
