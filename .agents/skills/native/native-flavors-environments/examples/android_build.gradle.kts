android {
    ...
    flavorDimensions += "default"

    productFlavors {
        create("dev") {
            dimension = "default"
            applicationIdSuffix = ".dev"
            manifestPlaceholders["appName"] = "App Dev"
            manifestPlaceholders["appIcon"] = "@mipmap/ic_launcher_dev"
        }
        create("stage") {
            dimension = "default"
            applicationIdSuffix = ".stage"
            manifestPlaceholders["appName"] = "App Staging"
            manifestPlaceholders["appIcon"] = "@mipmap/ic_launcher_stage"
        }
        create("prod") {
            dimension = "default"
            manifestPlaceholders["appName"] = "App"
            manifestPlaceholders["appIcon"] = "@mipmap/ic_launcher"
        }
    }
}
