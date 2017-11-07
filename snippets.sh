shopt -s extglob
while [[ 1 ]]
do
    read -p "Please make a selection, select q to quit: " choice
    case $choice in
            # Check for digits
    +([0-9]))
         echo $choice ;;
     q|Q)
         break
           ;;
      *)
           echo "Invalid choice"
           ;;
    esac
done

STATES=(INITIAL DEFAULT_CS_SETUP CREATED_CS CHECKED_OUT_DIR MKELEMENT_FILE CREATED_BRANCH CHECKED_IN_DIR COMPLETE)
tam=${#STATES[@]}
for ((i=0; i < $tam; i++)); do
    name=${STATES[i]}
    declare -r ${name}=$i
done

echo get the INITIAL state
echo ${STATES[$INITIAL]}

echo get the next state from CREATED_CS
echo ${STATES[$CREATED_CS+1]}

echo list elements from CREATED_CS to the end
for ((i=$CREATED_CS; i < $tam; i++)); do
    echo ${STATES[$i]}
done

echo list elements from CREATED_CS to CREATED_BRANCH
for ((i=$CREATED_CS; i <= $CREATED_BRANCH; i++)); do
    echo ${STATES[$i]}
done
