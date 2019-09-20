#!/bin/bash
## Script to delete Ranger Users from database
## Usage: deleteUser.sh -f input.txt -u ranger_user -p password -db ranger [-r <replaceUser>]
##    -f       contains newline separated list of users to be deleted
##    -u       db user name
##    -p       db user password
##    -db      db name
##    -r       (optional) User to be used to replace references of deleted user. If not provided, `admin` will be used.

superuser="admin";

usage() {
  [ "$*" ] && echo "$0: $*"
  sed -n '/^##/,/^$/s/^## \{0,1\}//p' "$0"
  exit 2
} 2>/dev/null


while [ "$1" != "" ]; do
    case $1 in
        -f | --file )           shift
                                filename=$1
                                ;;
        -u | --username )		shift
								user=$1
                                ;;
        -p | --password )		shift
								passwd=$1
                                ;;
        -r | --replaceUser )	shift
								superuser=$1
                                ;;
        -db | --db )            shift
								dbname=$1
								;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

if [ -z "$filename" ];	then	usage; exit 1; fi 
if [ -z "$user" ];		then	usage; exit 1; fi 
if [ -z "$passwd" ];	then	usage; exit 1; fi 
if [ -z "$dbname" ];	then	usage; exit 1; fi 

mysqlex="mysql -u${user} -p${passwd} $dbname"

$mysqlex  <<EOF
DELIMITER $$
CREATE PROCEDURE deleteUserByUsername(username varchar(1024), superuser varchar(1024))
BEGIN
declare xuser_id bigint;
declare x_portal_user_id bigint;
declare superuser_id bigint;
	set xuser_id = (select id from x_user where user_name=username);
	if (xuser_id is not null) then
		delete from x_audit_map where user_id = xuser_id;
		delete from x_group_users where user_id = xuser_id;
		delete from x_perm_map where user_id = xuser_id;
		delete from x_user where id = xuser_id;
	end if;
	set x_portal_user_id = (select id from x_portal_user where login_id=username);
	if(x_portal_user_id is not null) then
		set superuser_id = (select id from x_portal_user where login_id = superuser);
		if(superuser_id is null) then
			set superuser_id = (select user_id from x_portal_user_role where user_role = "ROLE_SYS_ADMIN" and status = 1 LIMIT 1);
		end if;
		update x_asset set added_by_id=superuser_id where added_by_id=x_portal_user_id;
		update x_asset set upd_by_id=superuser_id where upd_by_id=x_portal_user_id;
		update x_audit_map set added_by_id=superuser_id where added_by_id=x_portal_user_id;
		update x_audit_map set upd_by_id=superuser_id where upd_by_id=x_portal_user_id;
		update x_auth_sess set added_by_id=superuser_id where added_by_id=x_portal_user_id;
		update x_auth_sess set upd_by_id=superuser_id where upd_by_id=x_portal_user_id;
		update x_cred_store set added_by_id=superuser_id where added_by_id=x_portal_user_id;
		update x_cred_store set upd_by_id=superuser_id where upd_by_id=x_portal_user_id;
		update x_group set added_by_id=superuser_id where added_by_id=x_portal_user_id;
		update x_group set upd_by_id=superuser_id where upd_by_id=x_portal_user_id;
		update x_group_groups set added_by_id=superuser_id where added_by_id=x_portal_user_id;
		update x_group_groups set upd_by_id=superuser_id where upd_by_id=x_portal_user_id;
		update x_group_users set added_by_id=superuser_id where added_by_id=x_portal_user_id;
		update x_group_users set upd_by_id=superuser_id where upd_by_id=x_portal_user_id;
		update x_perm_map set added_by_id=superuser_id where added_by_id=x_portal_user_id;
		update x_perm_map set upd_by_id=superuser_id where upd_by_id=x_portal_user_id;
		update x_policy_export_audit set added_by_id=superuser_id where added_by_id=x_portal_user_id;
		update x_policy_export_audit set upd_by_id=superuser_id where upd_by_id=x_portal_user_id;
		update x_portal_user set added_by_id=superuser_id where added_by_id=x_portal_user_id;
		update x_portal_user set upd_by_id=superuser_id where upd_by_id=x_portal_user_id;
		update x_portal_user_role set added_by_id=superuser_id where added_by_id=x_portal_user_id;
		update x_portal_user_role set upd_by_id=superuser_id where upd_by_id=x_portal_user_id;
		update x_resource set added_by_id=superuser_id where added_by_id=x_portal_user_id;
		update x_resource set upd_by_id=superuser_id where upd_by_id=x_portal_user_id;
		update x_trx_log set added_by_id=superuser_id where added_by_id=x_portal_user_id;
		update x_trx_log set upd_by_id=superuser_id where upd_by_id=x_portal_user_id;
		update x_user set added_by_id=superuser_id where added_by_id=x_portal_user_id;
		update x_user set upd_by_id=superuser_id where upd_by_id=x_portal_user_id;
		delete from x_auth_sess where user_id = x_portal_user_id;
		delete from x_portal_user_role where user_id = x_portal_user_id;
		delete from x_portal_user where id = x_portal_user_id;
        update x_service_def set added_by_id=null where added_by_id=x_portal_user_id;
        update x_service_def set upd_by_id=null where upd_by_id=x_portal_user_id;
        update x_service set added_by_id=null where added_by_id=x_portal_user_id;
        update x_service set upd_by_id=null where upd_by_id=x_portal_user_id;
        update x_policy set added_by_id=null where added_by_id=x_portal_user_id;
        update x_policy set upd_by_id=null where upd_by_id=x_portal_user_id;
        update x_service_config_def set added_by_id=null where added_by_id=x_portal_user_id;
        update x_service_config_def set upd_by_id=null where upd_by_id=x_portal_user_id;
        update x_resource_def set added_by_id=null where added_by_id=x_portal_user_id;
        update x_resource_def set upd_by_id=null where upd_by_id=x_portal_user_id;
        update x_access_type_def set added_by_id=null where added_by_id=x_portal_user_id;
        update x_access_type_def set upd_by_id=null where upd_by_id=x_portal_user_id;
        update x_access_type_def_grants set added_by_id=null where added_by_id=x_portal_user_id;
        update x_access_type_def_grants set upd_by_id=null where upd_by_id=x_portal_user_id;
        update x_policy_condition_def set added_by_id=null where added_by_id=x_portal_user_id;
        update x_policy_condition_def set upd_by_id=null where upd_by_id=x_portal_user_id;
        update x_context_enricher_def set added_by_id=null where added_by_id=x_portal_user_id;
        update x_context_enricher_def set upd_by_id=null where upd_by_id=x_portal_user_id;
        update x_enum_def set added_by_id=null where added_by_id=x_portal_user_id;
        update x_enum_def set upd_by_id=null where upd_by_id=x_portal_user_id;
        update x_enum_element_def set added_by_id=null where added_by_id=x_portal_user_id;
        update x_enum_element_def set upd_by_id=null where upd_by_id=x_portal_user_id;
        update x_service_config_map set added_by_id=null where added_by_id=x_portal_user_id;
        update x_service_config_map set upd_by_id=null where upd_by_id=x_portal_user_id;
        update x_policy_resource set added_by_id=null where added_by_id=x_portal_user_id;
        update x_policy_resource set upd_by_id=null where upd_by_id=x_portal_user_id;
        update x_policy_resource_map set added_by_id=null where added_by_id=x_portal_user_id;
        update x_policy_resource_map set upd_by_id=null where upd_by_id=x_portal_user_id;
        update x_policy_item set added_by_id=null where added_by_id=x_portal_user_id;
        update x_policy_item set upd_by_id=null where upd_by_id=x_portal_user_id;
        update x_policy_item_access set added_by_id=null where added_by_id=x_portal_user_id;
        update x_policy_item_access set upd_by_id=null where upd_by_id=x_portal_user_id;
        update x_policy_item_condition set added_by_id=null where added_by_id=x_portal_user_id;
        update x_policy_item_condition set upd_by_id=null where upd_by_id=x_portal_user_id;
        update x_policy_item_user_perm set added_by_id=null where added_by_id=x_portal_user_id;
        update x_policy_item_user_perm set upd_by_id=null where upd_by_id=x_portal_user_id;
        update x_policy_item_group_perm set added_by_id=null where added_by_id=x_portal_user_id;
        update x_policy_item_group_perm set upd_by_id=null where upd_by_id=x_portal_user_id;
        update x_modules_master set added_by_id=null where added_by_id=x_portal_user_id;
        update x_modules_master set upd_by_id=null where upd_by_id=x_portal_user_id;
        update x_user_module_perm set added_by_id=null where added_by_id=x_portal_user_id;
        update x_user_module_perm set upd_by_id=null where upd_by_id=x_portal_user_id;
        update x_group_module_perm set added_by_id=null where added_by_id=x_portal_user_id;
        update x_group_module_perm set upd_by_id=null where upd_by_id=x_portal_user_id;
        update x_tag_def set added_by_id=null where added_by_id=x_portal_user_id;
        update x_tag_def set upd_by_id=null where upd_by_id=x_portal_user_id;
        update x_tag_attr_def set added_by_id=null where added_by_id=x_portal_user_id;
        update x_tag_attr_def set upd_by_id=null where upd_by_id=x_portal_user_id;
        update x_service_resource set added_by_id=null where added_by_id=x_portal_user_id;
        update x_service_resource set upd_by_id=null where upd_by_id=x_portal_user_id;
        update x_service_resource_element set added_by_id=null where added_by_id=x_portal_user_id;
        update x_service_resource_element set upd_by_id=null where upd_by_id=x_portal_user_id;
        update x_service_resource_element_val set added_by_id=null where added_by_id=x_portal_user_id;
        update x_service_resource_element_val set upd_by_id=null where upd_by_id=x_portal_user_id;
        update x_tag set added_by_id=null where added_by_id=x_portal_user_id;
        update x_tag set upd_by_id=null where upd_by_id=x_portal_user_id;
        update x_tag_attr set added_by_id=null where added_by_id=x_portal_user_id;
        update x_tag_attr set upd_by_id=null where upd_by_id=x_portal_user_id;
        update x_tag_resource_map set added_by_id=null where added_by_id=x_portal_user_id;
        update x_tag_resource_map set upd_by_id=null where upd_by_id=x_portal_user_id;
	end if;
END
EOF

while read line
do
    name=$(echo $line)
	if [ -z "$name" ]; then	continue; fi
		name=$(echo "$name" | sed "s|\\\0|\\\\\\0|g")
		name=$(echo "$name" | sed "s|'|\\\'|g")
		name=$(echo "$name" | sed "s|%|\\\%|g")
		name=$(echo "$name" | sed "s|\\\_|\\\\\\\_|g")
		name=$(echo "$name" | sed "s|Z|\\\Z|g")
    echo "  Deleting user : $name"
    $mysqlex -e "CALL deleteUserByUsername(\"$name\", \"$superuser\")"
done < $filename

$mysqlex -e "SET FOREIGN_KEY_CHECKS=0;DROP PROCEDURE IF EXISTS deleteUserByUsername;SET FOREIGN_KEY_CHECKS=1"

echo "Deleted all Users successfully"
