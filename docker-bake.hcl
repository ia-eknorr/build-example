variable "APP_VERSION" {
    default = "0.0.1"
}

variable "CONTAINER_REGISTRY" {
	default = "localhost:5000"
}

variable "BASE_IMAGE_NAME" {
    default = "example-ignition"
}

target "default" {
    context = "build"
    tags = [
		"${CONTAINER_REGISTRY}/${BASE_IMAGE_NAME}:${APP_VERSION}",
        "${CONTAINER_REGISTRY}/${BASE_IMAGE_NAME}:latest"
    ]
}
