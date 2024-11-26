#!/usr/bin/env bash

# Enable error handling
trap handle_error ERR

args=("$@")

# Declare a map of any potential wrapper arguments to be passed into Ignition upon startup
declare -A wrapper_args_map=(
	["-Dignition.projects.scanFrequency"]=${PROJECT_SCAN_FREQUENCY:-10} # Disable console logging
)

# Declare a map of potential jvm arguments to be passed into Ignition upon startup, before the wrapper args
declare -A jvm_args_map=()

main() {
	echo "Starting custom Ignition gateway initialization"

	# Have some fun
	have_some_fun

	# Prepare arguments for launching Ignition
	prepare_launch_args

	# Launch Ignition
	launch_ignition "${args[@]}"
}

################################################################################
# Run have-some-fun.sh
################################################################################
have_some_fun() {
    /usr/local/bin/have-some-fun.sh
}

################################################################################
# Prepare the launch arguments for Ignition by converting the associative arrays to index arrays
################################################################################
prepare_launch_args() {
	# Convert wrapper args associative array to index array prior to launch
	local wrapper_args=()
	for key in "${!wrapper_args_map[@]}"; do
		wrapper_args+=("${key}=${wrapper_args_map[${key}]}")
		echo "Collected wrapper arg: ${key}=${wrapper_args_map[${key}]}"
	done

	# Convert jvm args associative array to index array prior to launch
	local jvm_args=()
	for key in "${!jvm_args_map[@]}"; do
		jvm_args+=("${key}" "${jvm_args_map[${key}]}")
		echo "Collected JVM arg: ${key} ${jvm_args_map[${key}]}"
	done

	# If "--" is already in the args, insert any jvm args before it, else if it isn't there just append the jvm args
	if [[ " ${args[*]} " =~ " -- " ]]; then
		# Insert the jvm args before the "--" in the args array
		args=("${args[@]/#-- /-- ${jvm_args[*]} }")
	else
		# Append the jvm args to the args array
		args+=("${jvm_args[@]}")
	fi

	# If "--" is not already in the args, make sure you append it before the wrapper args
	[[ ! " ${args[*]} " =~ " -- " ]] && args+=("--")

	# Append the wrapper args to the provided args
	args+=("${wrapper_args[@]}")
}

################################################################################
# Start the official images entrypoint script
################################################################################
launch_ignition() {
	# Run the entrypoint
	# Check if docker-entrypoint is not in bin directory
	if [ ! -e /usr/local/bin/docker-entrypoint.sh ]; then
		# Run the original entrypoint script
		mv docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
	fi

	echo "Launching Ignition with args: $*"
	echo "Finished custom Ignition gateway initialization"
	echo ""
	exec docker-entrypoint.sh "$@"
}

main "${args[@]}"