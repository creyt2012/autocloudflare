
#!/bin/bash

# Forked from creyt/cloudflare-update-record.sh
# CHANGE THESE
#API token của cloudflare
auth_token="zu90zrjZV1Q6NstJEG2i9eeoabFfmBULKEvq_h5L"
# Domain and DNS record for synchronization
zone_identifier="127831543b81a59694614cbc5d8cf516" # Can be found in the "Overview" tab of your domain
record_name="dns.4gspeed.me"        

# Which record you want to be synced

# DO NOT CHANGE LINES BELOW

# SCRIPT START
echo -e "Đang kiểm tra ip"

# Check for current external network IP
ip=$(curl -s4 https://icanhazip.com/)
if [[ ! -z "${ip}" ]]; then
  echo -e "  > Ip hiện tại của server: ${ip}"
else
  >&2 echo -e "Lỗi mạng, không thể tìm nạp IP mạng bên ngoài."
fi

# The execution of update
if [[ ! -z "${auth_token}" ]]; then
  header_auth_paramheader=( -H '"Authorization: Bearer '${auth_token}'"' )
else
  header_auth_paramheader=( -H '"X-Auth-Email: '${auth_email}'"' -H '"X-Auth-Key: '${auth_key}'"' )
fi

# Seek for the record
seek_current_dns_value_cmd=( curl -s -X GET '"https://api.cloudflare.com/client/v4/zones/'${zone_identifier}'/dns_records?name='${record_name}'&type=A"' "${header_auth_paramheader[@]}" -H '"Content-Type: application/json"' )
record=`eval ${seek_current_dns_value_cmd[@]}`

# Can't do anything without the record
if [[ -z "${record}" ]]; then
  >&2 echo -e "Lỗi mạng, không thể tìm nạp bản ghi DNS."
  exit 1
elif [[ "${record}" == *'"count":0'* ]]; then
  >&2 echo -e "Bản ghi không tồn tại, hãy tạo một bản ghi trước"
  exit 1
fi

# Set the record identifier from result
record_identifier=`echo "${record}" | sed 's/.*"id":"//;s/".*//'`

# Set existing IP address from the fetched record
old_ip=`echo "${record}" | sed 's/.*"content":"//;s/".*//'`
echo -e "  > Đã tìm nạp giá trị bản ghi DNS hiện tại  : ${old_ip}"

# Compare if they're the same
if [ "${ip}" == "${old_ip}" ]; then
  echo -e "Cập nhật cho bản ghi A '${record_name} (${record_identifier})' đã hủy bỏ.\\n  Lý do: IP không thay đổi."
  exit 0
else
  echo -e "  > Đã phát hiện các địa chỉ IP khác nhau, đang đồng bộ hóa..."
fi

# The secret sause for executing the update
json_data_v4="'"'{"id":"'${zone_identifier}'","type":"A","proxied":true,"name":"'${record_name}'","content":"'${ip}'","ttl":120}'"'"
update_cmd=( curl -s -X PUT '"https://api.cloudflare.com/client/v4/zones/'${zone_identifier}'/dns_records/'${record_identifier}'"' "${header_auth_paramheader[@]}" -H '"Content-Type: application/json"' )

# Execution result
update=`eval ${update_cmd[@]} --data $json_data_v4`

# The moment of truth
case "$update" in
*'"success":true'*)
  echo -e "Cập nhật cho bản ghi A '${record_name} (${record_identifier})' đã thành công.\\n  - Old value: ${old_ip}\\n  +Giá trị mới: ${ip}";;
*)
  >&2 echo -e "Cập nhật cho bản ghi A'${record_name} (${record_identifier})' thất bại.\\n Kết quả không thành công:\\n${update}"
  exit 1;;
esac
