
function ainstance() {
	local IFS=$'\n'
	instances=($(aws ec2 describe-instances \
		--query "Reservations[*].Instances[*].[InstanceId,InstanceType,AvailabilityZone,InstanceLifecycle,State.Name]"))
	echo "Select instance:"
	for ((i=1; i <= ${#instances[@]}; i++)); do
			echo "[$i] ${instances[i-1]}"
	done
	echo "[q] quit"
	echo

	local IFS=$'\t'
	while [[ 1 ]]
	do
	    read -p "Please make a selection: " choice
	    case $choice in
				[1-${#instances[@]}] )
					description=(${instances[$choice-1]})
					export defaultId=${description[0]}
					break ;;
				q|Q ) break ;;
	      * ) echo "Invalid choice" ;;
	    esac
	done
	aip
}

function aattach(){
	selectedId=${1:-$defaultId};
	aws ec2 attach-volume --volume-id vol-0644b68ff463cc625 --instance-id $selectedId --device /dev/sdf
	alogin
}

function aup() {
	instanceId=${1:-$defaultId};
	echo "$instanceId";
	aws ec2 start-instances --instance-ids "$instanceId";
	aws ec2 wait instance-running --instance-ids "$instanceId";
	instanceIp=$(aws ec2 describe-instances \
		--filters "Name=instance-id,Values=$instanceId" \
		--query "Reservations[0].Instances[0].PublicIpAddress");
	url="$instanceIp:8888";
	if [[ -n $(uname -r | fgrep -i microsoft) ]]; then
		echo $url | clip.exe;
		echo "$url copied to clipboard";
	else
		xdg-open http://$instanceIp:8888 2>&1 &
	fi
}

function adown() {
	instanceId=${1:-$defaultId};
	echo "$instanceId";
	aws ec2 stop-instances --instance-ids "$instanceId";
}

function astate() {
	instanceId=${1:-$defaultId};
	echo "$instanceId";
	aws ec2 describe-instances \
		--instance-ids $instanceId \
		--query "Reservations[0].Instances[0].[State.Name, PublicIpAddress, InstanceType]";
}

function alogin() {
	selectedIp=${1:-$instanceIp};
	echo "$selectedIp - $pem"
	ssh -q -i ~/.ssh/"$pem" ubuntu@"$selectedIp";
}

function aip() {
	instanceId=${1:-$defaultId};
	echo "$instanceId";
	export instanceIp=$(aws ec2 describe-instances \
		--filters "Name=instance-id,Values=$instanceId" \
		--query "Reservations[0].Instances[0].PublicIpAddress");
	echo $instanceIp;
}

function atype() {
	instanceId=${1:-$defaultId} ;
	astate $instanceId ;
	echo

	TYPES=(t2.micro t2.medium t2.xlarge p2.xlarge)
	echo "Options:"
	for ((i=1; i <= ${#TYPES[@]}; i++)); do
			echo "[$i] ${TYPES[i-1]}"
	done
	echo "[q] quit"
	echo

	while [[ 1 ]]
	do
	    read -p "Please make a selection: " choice
	    case $choice in
				[1-${#TYPES[@]}] )
					aws ec2 modify-instance-attribute \
						--instance-id $instanceId \
						--instance-type ${TYPES[$choice-1]} ;
					astate $instanceId ;
					break ;;
				q|Q ) break ;;
	      * ) echo "Invalid choice" ;;
	    esac
	done
}

function acopy() {
	scp -i ~/.ssh/$pem ubuntu@$instanceIp:$1 .
}

function ln_random() {
	for file in $(ls $1 | sort -R | head -n$2)
	do
		ln -s $1$file
	done
}
