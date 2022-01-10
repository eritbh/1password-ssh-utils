# Signs into `op` or exits the script
function op_signin {
	echo "Signing into 1Password..."
	eval "$(op signin $@ || echo 'echo "Sign-in failed." >&2; exit 1')"
}

# Ideally something that won't ever actually be written to disk, but we'll worry
# about that later
export default_temp_storage_root="/tmp/op-ssh-utils"

# Writes the public/private key pair for a given vault item to the temporary
# storage directory, and adds a rule to the temporary ssh config for the host
# and user.
function configure_keys {
	temp_storage_root=$1
	uuid=$2
	public_key=$3
	private_key=$4
	host=$5
	user=$6

	# Initialize storage directory if not set up yet
	mkdir -p "$temp_storage_root/keys"
	if [ ! -f "$temp_storage_root/ssh_config" ]; then
		echo > "$temp_storage_root/ssh_config"
	fi

	touch "$temp_storage_root/keys/$uuid"
	chmod 0600 "$temp_storage_root/keys/$uuid"
	echo "$private_key" > "$temp_storage_root/keys/$uuid"

	touch "$temp_storage_root/keys/$uuid.pub"
	chmod 0644 "$temp_storage_root/keys/$uuid.pub"
	echo "$public_key" > "$temp_storage_root/keys/$uuid.pub"

	cat <<-SSH_CONFIG >> "$temp_storage_root/ssh_config"
		Match host $host user $user
		  IdentityFile $temp_storage_root/keys/$uuid
	SSH_CONFIG
}
