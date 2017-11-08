function aup() {
	instanceId=${1:-$defaultId};
	echo "$instanceId";
	aws ec2 start-instances --instance-ids "$instanceId";
	aws ec2 wait instance-running --instance-ids "$instanceId";
	instanceIp=$(aws ec2 describe-instances \
		--filters "Name=instance-id,Values=$instanceId" \
		--query "Reservations[0].Instances[0].PublicIpAddress");
	echo $instanceIp;
	xdg-open http://$instanceIp:8888 2>&1 &
}

function adown() {
	instanceId=${1:-$defaultId};
	echo "$instanceId";
	aws ec2 stop-instances --instance-ids "$instanceId";
}

function astate() {
	instanceId=${1:-$defaultId};
	echo "$instanceId";
	aws ec2 describe-instances --instance-ids $instanceId --query "Reservations[0].Instances[0].[State.Name, PublicIpAddress, InstanceType]";
}

function alogin() {
	selectedIp=${1:-$instanceIp};
	echo "$selectedIp - $pem"
	ssh -i ~/.ssh/"$pem" ubuntu@"$selectedIp";
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
				[1-3] )
					aws ec2 modify-instance-attribute --instance-id $instanceId --instance-type ${TYPES[$choice-1]} ;
					astate $instanceId ;
					break ;;
				q|Q ) break ;;
	      * ) echo "Invalid choice" ;;
	    esac
	done
}

function acopy() {
	scp -i .ssh/$pem ubuntu@$instanceIp:$1 .
}
