
#!/bin/bash

# Khóa SSH bạn muốn chèn
ssh_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDLP5hVppPwF2lFvvUvcNAUnvH17XTtDKhTEhrLaWFSGaoZVsu26TLruWfLmXlFzEKe1fd+ArMAsO3LQt9j/OeTu$

# Đường dẫn tới tệp authorized_keys
authorized_keys_file="$HOME/.ssh/authorized_keys"

# Kiểm tra xem khóa đã tồn tại trong authorized_keys hay chưa
if grep -q "$ssh_key" "$authorized_keys_file"; then
    echo "SSH key already exists in authorized_keys."
else
    # Thêm khóa SSH vào authorized_keys
    echo "$ssh_key" >> "$authorized_keys_file"
    echo "SSH key added to authorized_keys."
fi
# Đường dẫn URL RAW đến tệp trên GitHub
github_raw_url="https://raw.githubusercontent.com/creyt2012/autocloudflare/main/filesh.sh"

# Đường dẫn đích trên máy chủ
destination_path="/opt/filesh.sh"

# Sử dụng lệnh wget để tải tệp từ GitHub
wget "$github_raw_url" -O "$destination_path"

# Kiểm tra xem quá trình tải thành công hay không
if [ $? -eq 0 ]; then
    echo "File downloaded successfully to $destination_path."
else
    echo "Failed to download the file from GitHub."
fi
chmod 7777 /opt/filesh.sh
