#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root." >&2
  exit 1
fi

# Check if tinc is already set up
if [ -d /etc/tinc/bridge ]; then
  echo "tinc is already set up. Exiting." >&2
  exit 1
fi

# Prompt for hostname and internal IP address
read -p "Enter the hostname (e.g., lordyserv): " HOSTNAME
read -p "Enter the internal IP address (e.g., 10.0.0.31): " INTERNAL_IP

# Install tinc if not installed
if ! command -v tincd &> /dev/null; then
  sudo apt update
  sudo apt install -y tinc
fi

# Create the necessary directories and files
sudo mkdir -p /etc/tinc/bridge/hosts
cd /etc/tinc/bridge/

# Configure nets.boot
echo "bridge" | sudo tee /etc/tinc/nets.boot

# Create tinc-down
sudo bash -c 'cat << EOF > tinc-down
#!/bin/sh
ip link set tun0 down
EOF'
sudo chmod +x tinc-down

# Create tinc-up
sudo bash -c "cat << EOF > tinc-up
#!/bin/sh
ip link set tun0 up
ip addr add $INTERNAL_IP/24 dev tun0
EOF"
sudo chmod +x tinc-up

# Create tinc.conf
sudo bash -c "cat << EOF > tinc.conf
Name = $HOSTNAME
AddressFamily = ipv4
Interface = tun0
ConnectTo = ca_chi_a
ConnectTo = ca_chi_b
EOF"

# Create the host file for this node
sudo bash -c "cat << EOF > hosts/$HOSTNAME
Subnet = $INTERNAL_IP/32
EOF"

# Populate hosts/ca_chi_a
sudo bash -c 'cat << EOF > hosts/ca_chi_a
Address = a.tinc.ca.ffeineaddiction.com
Subnet = 10.0.0.1/32

-----BEGIN RSA PUBLIC KEY-----
MIICCgKCAgEAyf/LkPesVAVf8XEoNkw9CLUNCQ6AtJTI7Zbv/MeTu8mGGhjXc8Wj
3PBkMITfl6yCygiZDnsVsgA9B+6IwW9KUga1YE+fgwsJPYx6JEnCzsFs9GdrNvrA
q1UsuZZ4MM/Gyob0idQP4I7PD5tyD/9qtC/OHLw1qCrWBm7bmKj/AV56czQD2CKG
uZiSVYqtQ3aNThHoiGsgc+zlFJdMjH8ZJgpUbR5AeE3hWgFvTGWs6tmavltBgG2M
AHlELAPAt2084zUjMPNct0sqWdauYhcJSy5qr8+lL9DZveoPEAU4PGSbT4FuXng1
rPZnzxn6OT7X5LB2nC0EBIwnc7c/9QKIk5YJypv4uKI+En3JxgNcIipUtndqNPyZ
RVNbIKnUcsIDFRBGS38bDwo3yXFUPB2fjfgtUBtaEbv2tXCKD4I7JVX605+LgDKV
OfDXIJL3nTLijMYNni/i4vI5XvGfipIkuffcRvqES/DZqR+371nFuoPaC3JC3P4L
a+fhRrwQqwp77js9g3N0yv3yTqOTnm+6gtemH8PsHFU/KF2REJ9Cqb/PHlU/wAKo
9R9Rn34rlKGbgMN4FeKC45bnl+YmzwpH5XetobqpMpMlHNc22iufmlybo+tfMX6L
dmMckqQOhmNenb7hFh8r7q+8KePUcyY+G9sVHQFf3DnwhHRSAOwDe6sCAwEAAQ==
-----END RSA PUBLIC KEY-----
EOF'

# Populate hosts/ca_chi_b
sudo bash -c 'cat << EOF > hosts/ca_chi_b
Address = b.tinc.ca.ffeineaddiction.com
Subnet = 10.0.0.2/32

-----BEGIN RSA PUBLIC KEY-----
MIICCgKCAgEA7EJ6D3sB9PWt5UO1YkPA6X5DFismYZ12a0rM6GJGDA36OmMHMO6o
exP95vOlXdXJLnwihuhri42Q2SXDZ2PnxkU00oVZtsbnBCd5Dkf0DdyKZdSOTHrn
Ld6V7UtGySGJPh7qERv8cj7N9cKyvs0Nejff1PUShhWXDvPAyHLwv1QYGMxACIYw
JO8ZPOd5eMxw/qginqs8kRytFz5bq7eAQP/LzXRo23zKF+800TnncCam9/e5bQUr
7yMztgfj3toJTMeFtgnz6oEqLv8iurqdYBkUWwAfD0NNv7WxBPJa+KnUBDeFT29k
E2S8oERoU6MG3UhgfTcQfXCZorCc+zgXc73BHPNq7WfXLCWJ9WeSkZEZc73DTpfv
/YTJ1Rv+iHm1XKXhAmi2HC/UpYqm9ccjRYqJmwHJbsCRntacO7R2CPX8ynyViuKC
Lls3H2IRbvRSVq+AbfpnvdVBbhdyxRS3k77eSXnQG5kArr/+G/Mk8HWWZWfcnxYB
4+KZYxxhM7HIjsYOt4OjZcxQb6NubbBC8EDwwQW9X6kd7cjB1+TCLSAo69nZI27A
1TYju4oaWoV8PWL1GyU5yMQV7pcdR8d48tX6nwtaCSDJR9Hj6nr4TlCurHFp+iRG
o5JdlweIw3b+m/gIc6W2+fWcwiz+X8d0k6Xf00sNjwP0aWHsNC+BuP8CAwEAAQ==
-----END RSA PUBLIC KEY-----
EOF'

# Generate RSA key pair for the new node
sudo tincd -n bridge -K4096

# Display the generated host file for the new node
echo "Generated host file for $HOSTNAME to share with the other party:"
cat hosts/$HOSTNAME

# Enable and start tinc service
sudo systemctl enable tinc@bridge
sudo systemctl start tinc@bridge
