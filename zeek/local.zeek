@load packages

@load tuning/json-logs
redef LogAscii::use_json = T;

redef Site::local_nets += {
    10.0.0.0/8,
    172.16.0.0/12,
    192.168.0.0/16
};