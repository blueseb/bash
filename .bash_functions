alias ls='ls --color=auto'
alias ll='ls -hl'
alias dus='du -hd1 | sort -hr'

export mulettoId=i-0aac6b78303da37c6
export fastaiId=i-01c7164143bf3d720
export defaultId=$fastaiId

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
	aws ec2 describe-instances --instance-ids $instanceId --query "Reservations[0].Instances[0].State.Name";
}

function alogin() {
	selectedIp=${1:-$instanceIp};
	echo "$selectedIp"
	ssh -i ~/.ssh/aws-key-fast-ai.pem ubuntu@"$selectedIp";
}

function aip() {
	instanceId=${1:-$defaultId};
	echo "$instanceId";
	export instanceIp=$(aws ec2 describe-instances \
		--filters "Name=instance-id,Values=$instanceId" \
		--query "Reservations[0].Instances[0].PublicIpAddress");
	echo $instanceIp;
}
