```sh
select id from x_user where user_name= 'test1'; ## its 34
mysql> select id from x_portal_user where login_id= 'test1';   # its 32
delete from x_audit_map where user_id = 34;
delete from x_group_users where user_id = 34;
delete from x_perm_map where user_id = 34;
SET FOREIGN_KEY_CHECKS=0;
delete from x_user where id = 34;
delete from x_auth_sess where user_id = 32;
delete from x_portal_user_role where user_id = 32;
delete from x_portal_user where id = 32;
SET FOREIGN_KEY_CHECKS=1;
```

```
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



SELECT ID
SELECT ID FROM x_user_module_perm WHERE (ID = 82)"
 "
DELETE FROM x_user_module_perm WHERE (ID = 82)"
SELECT ID
SELECT ID FROM x_user_module_perm WHERE (ID = 83)"
 "
DELETE FROM x_user_module_perm WHERE (ID = 83)"
SELECT ID FROM x_portal_user_role WHERE (ID = 35)"
 "
DELETE FROM x_portal_user_role WHERE (ID = 35)"
SELECT ID FROM x_user WHERE (ID = 37)"	
 "
DELETE FROM x_user WHERE (ID = 37)"
SELECT ID FROM x_portal_user WHERE (ID = 35)"
 "
DELETE FROM x_portal_user WHERE (ID = 35)"
```
